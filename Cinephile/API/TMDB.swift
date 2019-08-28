//
//  TMDB.swift
//  Cinephile
//
//  Created by Felipe Alves on 28/08/19.
//  Copyright © 2019 Bolzaniapps. All rights reserved.
//

import Foundation
import ws
import then
import Arrow

enum TMDBError: Error {
    case noMorePagesToLoad
    case alreadyLoading
}

class TMDB {
    
    private static let baseUrl = "https://api.themoviedb.org"
    private static let apiKey = "1f54bd990f1cdfb230adb312546d765d"
    
}

// MARK: - Public

extension TMDB {
    
    static func upcoming() -> PagedRequest {
        return PagedRequest(WS(baseUrl).getRequest("/3/movie/upcoming", params: ["api_key":apiKey, "language": "en-US"]))
    }
    
    static func search(_ query: String) -> PagedRequest {
        return PagedRequest(WS(baseUrl).getRequest("/3/search/movie", params: ["api_key":apiKey, "language": "en-US", "include_adult": false]))
    }
}

// MARK: - PagedRequest

class PagedRequest {
    
    var loading: Bool = false
    private var nextPage: Int = 1
    private var call: WSRequest!
    private var canLoadMore = true
    
    init(_ aCall: WSRequest) {
        call = aCall
    }
    
    func reset() {
        call.cancel()
        nextPage = 1
        canLoadMore = true
    }
    
    func hasMoreToLoad() -> Bool {
        return canLoadMore
    }
    
    func loadNextPage() -> Promise<[Movie]> {
        guard canLoadMore else {
            return Promise.init(error: TMDBError.noMorePagesToLoad)
        }
        guard !loading else {
            return Promise.init(error: TMDBError.alreadyLoading)
        }
        loading = true
        var params = call.params
        params["page"] = nextPage
        call.params = params
        nextPage += 1
        return call.fetch()
            .registerThen(parsePage)
            .resolveOnMainThread()
    }
    
    private func parsePage(_ json: JSON) -> [Movie] {
        let mapper = WSModelJSONParser<ResultPage>()
        let aPage = mapper.toModel(json)
        canLoadMore = nextPage <= aPage.totalPages
        loading = false
        return aPage.results
    }
    
}
