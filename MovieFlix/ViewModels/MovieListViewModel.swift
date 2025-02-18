//
//  FavoriteMovieListViewModel.swift
//  MovieFlix
//
//  Created by Dimitrios Tsoumanis on 12/02/2025.
//

import Combine
import Foundation

final class MovieListViewModel {
    @Published private(set) var movies: [Movie] = []
    @Published var searchQuery = ""
    @Published private(set) var isLoading = false
    @Published var error: Error?
    
    private var currentPage = 1
    private var hasMorePages = true
    private var cancellables = Set<AnyCancellable>()
    private var currentTask: Task<Void, Never>?
    private var fetchMode: MovieFetchMode = .popular
    
    private let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
        
        $searchQuery
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                self?.updateFetchMode(query: query)
            }
            .store(in: &cancellables)
    }
    
    func loadMovies(
        isRefreshing: Bool = false,
        checkCancellation: Bool = false
    ) async {
        guard !isLoading, hasMorePages else { return }
        if isRefreshing {
            currentPage = 1
            movies.removeAll()
        }
        isLoading = true
        error = nil
        let endpoint: MovieAPI
        do {
            switch fetchMode {
            case .search(let query):
                endpoint = MovieAPI.searchMovie(term: query, page: currentPage)
            case .popular:
                endpoint = MovieAPI.fetchMovies(page: currentPage)
            }
            let response: WebResponse = try await apiClient.fetch(endpoint)
            guard !Task.isCancelled else { return }
            let newMovies = await updateMoviesWithFavorites(response.movies)
            if isRefreshing {
                self.movies = newMovies
            } else {
                self.movies.append(contentsOf: newMovies)
            }
            hasMorePages = currentPage < response.totalPages
            currentPage += 1
        } catch {
            self.error = error
        }
        isLoading = false
    }
    
    func toggleFavorite(at index: Int) {
        Task {
            let movieId = movies[index].id
            await FavoritesManager.shared.toggleFavorite(for: movieId)
            movies[index].isFavorite.toggle()
        }
    }
    
    private func updateMoviesWithFavorites(_ movies: [Movie]) async -> [Movie] {
        await withTaskGroup(of: (Int, Bool).self) { group in
            for (index, movie) in movies.enumerated() {
                group.addTask {
                    let isFav = await FavoritesManager.shared.isFavorite(movie.id)
                    return (index, isFav)
                }
            }
            
            var updatedMovies = movies
            for await (index, isFav) in group {
                updatedMovies[index].isFavorite = isFav
            }
            return updatedMovies
        }
    }
    
    private func updateFetchMode(query: String) {
        let newMode: MovieFetchMode = query.isEmpty ? .popular : .search(query: query)
                
        if newMode != fetchMode {
            hasMorePages = true
        }
        
        if query.isEmpty {
            fetchMode = newMode
            performSearch()
            return
        }
        
        guard newMode != fetchMode else {
            return
        }
        
        fetchMode = newMode
        performSearch()
    }
    
    private func performSearch() {
        currentTask?.cancel()
        
        currentTask = Task {
            await loadMovies(isRefreshing: true)
        }
    }
}

private enum MovieFetchMode: Equatable {
    case popular
    case search(query: String)
}
