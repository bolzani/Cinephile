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
    
    // MARK: Private Properties
    
    private static let baseUrl = "https://api.themoviedb.org"
    private static let apiKey = "1f54bd990f1cdfb230adb312546d765d"
    private static let requiredParameters: [String:Any] = ["api_key":apiKey, "language": "en-US"]
    private static let movieGenresPromise: Promise<[MovieGenre]> = createMovieGenresPromise()

    
}

// MARK: - Public Methods

extension TMDB {
    
    static func upcoming() -> PagedRequest {
        return PagedRequest(request(path: "/3/movie/upcoming"))
    }
    
    static func search(_ query: String) -> PagedRequest {
        return PagedRequest(request(path: "/3/search/movie", params: ["include_adult": false]))
    }
    
    static func genres() -> Promise<[MovieGenre]> {
        return movieGenresPromise
    }
    
    static func movie(_ id: Int) -> Promise<Movie> {
        return request(path: "/3/movie/\(id)")
            .fetch()
            .registerThen { (json: JSON) -> Promise<Movie> in
                let aMovie = Movie(json)!
                return Promise.resolve(aMovie)
        }.resolveOnMainThread()
    }
}

// MARK: - Private Methods

extension TMDB {
    
    private static func request(path: String, params extraParameters: [String:Any] = [:]) -> WSRequest {
        let params = requiredParameters.merging(extraParameters, uniquingKeysWith: { return $1 })
        return WS(baseUrl).getRequest(path, params: params)
    }
    
    private static func createMovieGenresPromise() -> Promise<[MovieGenre]> {
        return request(path: "/3/genre/movie/list")
            .fetch()
            .registerThen(parseGenres)
            .resolveOnMainThread()
    }
    
    private static func parseGenres(_ json: JSON) -> [MovieGenre] {
        let genres = json["genres"]?.collection?.compactMap({MovieGenre($0)}) ?? []
        return genres
    }
    
}

// MARK: - PagedRequest

class PagedRequest {
    
    var loading: Bool = false
    private var nextPage: Int = 1
    private var request: WSRequest!
    private var canLoadMore = true
    
    init(_ aRequest: WSRequest) {
        request = aRequest
    }
    
    func reset() {
        request.cancel()
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
        var params = request.params
        params["page"] = nextPage
        request.params = params
        nextPage += 1
        return request
            .fetch()
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
