//
//  MovieCast.swift
//  MovieFlix
//
//  Created by Dimitrios Tsoumanis on 18/02/2025.
//

import Foundation

struct MovieCastResponse: Decodable {
    let id: Int
    let cast: [Cast]
}

struct Cast: Decodable {
    let name: String
}
