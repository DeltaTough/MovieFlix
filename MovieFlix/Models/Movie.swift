//
//  Movie.swift
//  MovieFlix
//
//  Created by Dimitrios Tsoumanis on 12/02/2025.
//

struct WebResponse: Decodable {
    let page: Int
    let movies: [Movie]
    let totalPages: Int

    private enum CodingKeys: String, CodingKey {
        case page
        case movies = "results"
        case totalPages = "total_pages"
    }
}

struct Movie: Decodable, Identifiable {
    let id: Int
    let title: String
    let backdropPath: String?
    let releaseDate: String
    let voteAverage: Double
    var isFavorite: Bool = false
    
    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
    }
}
