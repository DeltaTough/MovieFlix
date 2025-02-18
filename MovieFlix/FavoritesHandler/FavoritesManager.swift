//
//  FavoritesManager.swift
//  MovieFlix
//
//  Created by Dimitrios Tsoumanis on 15/02/2025.
//

import Foundation

actor FavoritesManager {
    static let shared = FavoritesManager()
    
    private let defaults = UserDefaults.standard
    private let favoritesKey = "favoriteMovies"
    
    private var favorites: Set<Int> {
        get {
            let array = defaults.array(forKey: favoritesKey) as? [Int] ?? []
            return Set(array)
        }
        set {
            defaults.set(Array(newValue), forKey: favoritesKey)
        }
    }
    
    func toggleFavorite(for movieId: Int) {
        if favorites.contains(movieId) {
            favorites.remove(movieId)
        } else {
            favorites.insert(movieId)
        }
    }
    
    func isFavorite(_ movieId: Int) -> Bool {
        favorites.contains(movieId)
    }
}
