//
//  MovieDetail.swift
//  MovieFlix
//
//  Created by Dimitrios Tsoumanis on 16/02/2025.
//

import Foundation

struct MovieDetail: Decodable {
    let id: Int
    let backdropPath: String
    let genres: [Genre]
    let releaseDate: String
    let overview: String
    let homepage: String?
    let runtime: Int
    let title: String
    let voteAverage: Double
    var isFavorite: Bool = false

    private enum CodingKeys: String, CodingKey {
        case id
        case backdropPath = "backdrop_path"
        case genres
        case overview
        case homepage
        case releaseDate = "release_date"
        case runtime
        case title
        case voteAverage = "vote_average"
    }
}
