//
//  APIError.swift
//  MovieFlix
//
//  Created by Dimitrios Tsoumanis on 12/02/2025.
//

import Foundation

enum APIError: Error, Equatable {
    case invalidURL
    case invalidResponse
    case decodingError(Error)
    
    static func ==(lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL):
            return true
        case (.invalidResponse, .invalidResponse):
            return true
        case (.decodingError, .decodingError):
            return false
        default:
            return false
        }
    }
}
