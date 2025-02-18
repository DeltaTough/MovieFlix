//
//  MovieDetailsViewModel.swift
//  MovieFlix
//
//  Created by Dimitrios Tsoumanis on 16/02/2025.
//

import Combine
import UIKit

final class MovieDetailsViewModel: ObservableObject {
    @Published private(set) var image: UIImage? = nil
    @Published private(set) var images: [String: UIImage] = [:]
    @Published private(set) var movieDetails: MovieDetail? = nil
    @Published private(set) var releaseDate: String? = nil
    @Published private(set) var rating: Double? = nil
    @Published private(set) var runtime: Int? = nil
    @Published private(set) var cast: String? = nil
    @Published private(set) var reviews: [MovieReview]? = nil
    @Published private(set) var similarMoviesImages: [String]? = nil
    @Published private(set) var isFavorited: Bool? = nil
    @Published private(set) var isLoading: Bool = true
    
    private let movieId: Int
    private let apiClient: APIClientProtocol
    private var cancellables = Set<AnyCancellable>()
    private let cache = NSCache<NSString, UIImage>()
    
    init(movieId: Int, apiClient: APIClientProtocol) {
        self.movieId = movieId
        self.apiClient = apiClient
        Task {
            await fetchMovieData(movieId: movieId)
        }
        Task { @MainActor in
            isFavorited = await FavoritesManager.shared.isFavorite(movieId)
        }
    }
    
    func toggleFavorite() {
        self.isFavorited?.toggle()
    }
    
    @MainActor
    private func fetchMovieData(movieId: Int) async -> () {
        async let movieDetailsResponse = fetchMovieDetails(movieId: movieId)
        async let castResponse = fetchCast(movieId: movieId)
        async let reviewsResponse = fetchReviews(movieId: movieId)
        async let similarMoviesResponse = fetchSimilarMovies(movieId: movieId)
        
        let movieDetails = try? await movieDetailsResponse
        let cast = try? await castResponse
        let reviews = try? await reviewsResponse
        let similarMovies = try? await similarMoviesResponse
        
        if let movieDetails = movieDetails {
            fetchMovieImage(urlString: movieDetails.backdropPath)
        }
        self.movieDetails = movieDetails
        self.cast = cast?.compactMap(\.name).joined(separator: ", ")
        let sortReviewsByLength = reviews?.sorted { $0.content.count < $1.content.count }.prefix(2)
        self.reviews = Array(sortReviewsByLength ?? [])
        self.similarMoviesImages = similarMovies?.compactMap(\.backdropPath)
    }
    
    private func fetchMovieDetails(movieId: Int) async throws -> MovieDetail {
        try await apiClient.fetch(MovieAPI.details(movieId: movieId))
    }
    
    private func fetchCast(movieId: Int) async throws -> [Cast] {
        let endpoint = MovieAPI.cast(movieId: movieId)
        let response: MovieCastResponse = try await apiClient.fetch(endpoint)
        return response.cast
    }
    
    private func fetchReviews(movieId: Int) async throws -> [MovieReview] {
        let endpoint = MovieAPI.reviews(movieId: movieId)
        let response: MovieReviewResponse = try await apiClient.fetch(endpoint)
        return response.results
    }
    
    private func fetchSimilarMovies(movieId: Int) async throws -> [Movie] {
        let endpoint = MovieAPI.similar(movieId: movieId)
        let response: WebResponse = try await apiClient.fetch(endpoint)
        return response.movies
    }
    
    func shareInfo() {
        if let movieDetails, let shareURL = movieDetails.homepage {
            let activityVC = UIActivityViewController(activityItems: [shareURL], applicationActivities: nil)
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                rootVC.present(activityVC, animated: true, completion: nil)
            }
        }
    }
    
    func fetchMovieImage(urlString: String) {
        Task {
            do {
                let loadedImage = try await ImageLoader.shared.loadImage(
                    from: "https://image.tmdb.org/t/p/w500\(urlString)"
                )
                await MainActor.run {
                    self.image = loadedImage
                    self.isLoading = false
                }
            } catch {
                print("Failed to load image: \(error)")
            }
        }
    }
    
    func loadImage(for url: String) {
        if let cachedImage = cache.object(forKey: url as NSString) {
            DispatchQueue.main.async {
                self.images[url] = cachedImage
            }
            return
        }
        
        guard let imageURL = URL(string: "https://image.tmdb.org/t/p/w500\(url)") else { return }
        
        URLSession.shared.dataTaskPublisher(for: imageURL)
            .map { data, _ in UIImage(data: data) }
            .replaceError(with: nil)
            .receive(on: RunLoop.main)
            .sink { [weak self] downloadedImage in
                guard let self = self, let downloadedImage = downloadedImage else { return }
                self.cache.setObject(downloadedImage, forKey: url as NSString)
                self.images[url] = downloadedImage
            }
            .store(in: &cancellables)
    }
}

extension MovieDetailsViewModel {
    static func mock() -> MovieDetailsViewModel {
        return MovieDetailsViewModel(movieId: 550, apiClient: APIClient(baseURL: URL(string: "https://api.themoviedb.org/3")!))
    }
}
