//
//  MovieReview.swift
//  MovieFlix
//
//  Created by Dimitrios Tsoumanis on 18/02/2025.
//

import Foundation

struct MovieReviewResponse: Decodable {
    let id: Int
    let results: [MovieReview]
}

struct MovieReview: Decodable, Identifiable {
    var id: UUID = UUID()
    let author: String
    let content: String
    
    private enum CodingKeys: String, CodingKey {
        case author
        case content
    }
}
