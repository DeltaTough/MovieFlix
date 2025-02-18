//
//  MovieDetailsView.swift
//  MovieFlix
//
//  Created by Dimitrios Tsoumanis on 16/02/2025.
//

import SwiftUI

struct MovieDetailsView: View {
    @ObservedObject private var viewModel: MovieDetailsViewModel
    var onToggle: (() -> Void)?
    @State private var webViewHeight: CGFloat = 100
        
    init(viewModel: MovieDetailsViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        SkeletonShimmerView(isLoading: viewModel.isLoading) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ZStack {
                        if let image = viewModel.image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(3)
                                .overlay(
                                    Button(action: viewModel.shareInfo) {
                                        Image(systemName: "square.and.arrow.up")
                                            .font(.headline)
                                            .padding()
                                            .background(Color.white.opacity(0.7))
                                            .clipShape(Circle())
                                            .foregroundColor(.black)
                                            .opacity(viewModel.movieDetails?.homepage == nil ? 0 : 1)
                                    }
                                        .padding(),
                                    alignment: .bottomTrailing
                                )
                        }
                    }
                
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(viewModel.movieDetails?.title ?? "No Title")")
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            Text("\(viewModel.movieDetails?.genres.map(\.name).joined(separator: ", ") ?? "No Genres")")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        FavoriteButton(isFavorited: .constant(viewModel.isFavorited ?? false)) {
                            viewModel.toggleFavorite()
                            onToggle?()
                        }
                    }
                    
                    Text("\(viewModel.movieDetails?.releaseDate.formatDate() ?? "No Release Date")")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .padding(.leading, 2)
                    StarRatingViewWrapper(rating: viewModel.movieDetails?.voteAverage ?? 0)
                        .frame(width: 100, height: 16)
                    
                    Text("Runtime")
                        .font(.body)
                        .foregroundColor(.black)
                        .fontWeight(.bold)
                        .padding(.bottom, 2)
                    Text("\(viewModel.movieDetails?.runtime.convertRuntime() ?? "No Runtime")")
                        .font(.caption)
                        .foregroundColor(.orange)
                    
                    Text("Description")
                        .font(.body)
                        .fontWeight(.semibold)
                        .padding(.bottom, 2)
                    Text("\(viewModel.movieDetails?.overview ?? "No Description")")
                        .font(.caption2)
                    
                    Text("Cast")
                        .font(.body)
                        .fontWeight(.semibold)
                    
                    Text("\(viewModel.cast ?? "")")
                        .font(.caption2)
                        .fontWeight(.semibold)
                    
                    Group {
                        Text("Reviews")
                            .font(.body)
                            .fontWeight(.semibold)
                        
                        ScrollView {
                            LazyVStack(spacing: 10) {
                                ForEach(viewModel.reviews ?? [], id: \.id) { review in
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text(review.author)
                                            .font(.caption2)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.yellow)
                                        HTMLWebView(htmlContent: review.content,
                                                    dynamicHeight: $webViewHeight)
                                        .frame(height: webViewHeight)
                                    }
                                    .padding(.vertical, 5)
                                }
                            }
                        }
                    }.opacity(viewModel.reviews?.isEmpty ?? true ? 0 : 1)
                    
                    Group {
                        Text("Similar Movies")
                            .font(.body)
                            .fontWeight(.semibold)
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 10) {
                                ForEach(viewModel.similarMoviesImages ?? [], id: \.self) { url in
                                    MovieImageView(url: url, viewModel: viewModel)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }.opacity(viewModel.similarMoviesImages?.isEmpty ?? true ? 0 : 1)
                }
                .padding()
            }
        }
    }
}

struct MovieDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MovieDetailsView(viewModel: MovieDetailsViewModel.mock())
    }
}

struct FavoriteButton: View {
    @Binding var isFavorited: Bool
    var onToggle: () -> Void

    var body: some View {
        Button(action: {
            isFavorited.toggle()
            onToggle()
        }) {
            Image(systemName: isFavorited ? "heart.fill" : "heart")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundColor(.red)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MovieImageView: View {
    let url: String
    @ObservedObject var viewModel: MovieDetailsViewModel

    var body: some View {
        Group {
            if let image = viewModel.images[url] {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                ShimmerView()
                    .onAppear {
                        viewModel.loadImage(for: url)
                    }
            }
        }
        .frame(width: 150)
        .cornerRadius(10)
    }
}
