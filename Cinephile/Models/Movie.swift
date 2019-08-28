//
//  Movie.swift
//  Cinephile
//
//  Created by Felipe Alves on 28/08/19.
//  Copyright © 2019 Bolzaniapps. All rights reserved.
//

import Foundation
import Arrow

struct Movie {
    
    var popularity: Double = 0
    var voteCount: Int = 0
    var video: Bool = false
    var posterPath: String = ""
    var id: Int = 0
    var adult: Bool = false
    var backdropPath: String = ""
    var originalLanguage: String = ""
    var originalTitle: String = ""
    var genreIds: [Int] = []
    var title: String = ""
    var voteAverage: Double = 0
    var overview: String = ""
    var releaseDate: Date = Date()
    
    private let imagesBaseUrl = URL(string: "https://image.tmdb.org/t/p")!
}

// MARK: - Image Sizing

extension Movie {
    
    enum PosterSize: String {
        case w92
        case w154
        case w185
        case w342
        case w500
        case w780
        case original
    }
    
    enum BackdropSize: String {
        case w300
        case w780
        case w1280
        case original
    }
    
    func posterUrl(size: PosterSize) -> URL? {
        return URL(string: "\(size.rawValue)\(posterPath)", relativeTo: imagesBaseUrl)
    }
    
    func backdropUrl(size: BackdropSize) -> URL? {
        return URL(string: "\(size.rawValue)\(backdropPath)", relativeTo: imagesBaseUrl)
    }
}

// MARK: - ArrowParsable

extension Movie: ArrowParsable {

    mutating func deserialize(_ json: JSON) {
        popularity <-- json["popularity"]
        voteCount <-- json["vote_count"]
        video <-- json["video"]
        posterPath <-- json["poster_path"]
        id <-- json["id"]
        adult <-- json["adult"]
        backdropPath <-- json["backdrop_path"]
        originalLanguage <-- json["original_language"]
        originalTitle <-- json["original_title"]
        genreIds <-- json["genre_ids"]
        title <-- json["title"]
        voteAverage <-- json["vote_average"]
        overview <-- json["overview"]
        releaseDate <-- json["release_date"]?.dateFormat("YYYY-MM-DD")
    }
    
}
