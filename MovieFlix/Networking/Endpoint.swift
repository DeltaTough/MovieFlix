//
//  Endpoint.swift
//  MovieFlix
//
//  Created by Dimitrios Tsoumanis on 12/02/2025.
//

import Foundation

protocol Endpoint {
    var path: String { get }
    var method: String { get }
    var queryItems: [URLQueryItem]? { get }
    
    func urlRequest(baseURL: URL) -> URLRequest?
}

extension Endpoint  {
    var queryItems: [URLQueryItem]? { nil }
    
    func urlRequest(baseURL: URL) -> URLRequest? {
        var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)
        components?.queryItems = queryItems
        
        guard let url = components?.url else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        return request
    }
}


enum MovieAPI: Endpoint {
    case fetchMovies(page: Int)
    case searchMovie(term: String, page: Int)
    case details(movieId: Int)
    case cast(movieId: Int)
    case reviews(movieId: Int)
    case similar(movieId: Int)

    var path: String {
        switch self {
        case .fetchMovies:
            return "/movie/popular"
        case .searchMovie:
            return "/search/movie"
        case .details(let movieId):
            return "/movie/\(movieId)"
        case .cast(let movieId):
            return "/movie/\(movieId)/credits"
        case .reviews(let movieId):
            return "/movie/\(movieId)/reviews"
        case .similar(let movieId):
            return "/movie/\(movieId)/similar"
        }
    }

    var method: String {
        return "GET"
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case .fetchMovies(let page):
            return [URLQueryItem(name: "page", value: "\(page)")]
        case .searchMovie(let term, let page):
            return [URLQueryItem(name: "query", value: "\(term)"),
                    URLQueryItem(name: "page", value: "\(page)")]
        case .details(_):
            return nil
        case .cast(_):
            return nil
        case .reviews(_):
            return nil
        case .similar(_):
            return nil
        }
    }
}

