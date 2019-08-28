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

class PagedRequest {
    
    private var nextPage: Int = 1
    private var call: WSRequest!
    private var canLoadMore = true
    
    init(_ aCall: WSRequest) {
        call = aCall
    }
    
    func reset() {
        nextPage = 1
        canLoadMore = true
    }
    
    func hasMoreItemsToload() -> Bool {
        return canLoadMore
    }
    
    func fetchNext() -> Promise<[Movie]> {
        var params = call.params
        params["page"] = nextPage
        call.params = params
        return call.fetch()
            .registerThen(parsePage)
            .resolveOnMainThread()
    }
    
    private func parsePage(_ json: JSON) -> [Movie] {
        let mapper = WSModelJSONParser<ResultPage>()
        let aPage = mapper.toModel(json)
        nextPage += 1
        canLoadMore = nextPage <= aPage.totalPages
        return aPage.results
    }
    
}
