//
//  MovieListViewCell.swift
//  MovieFlix
//
//  Created by Dimitrios Tsoumanis on 12/02/2025.
//

import UIKit

class MovieListViewCell: UICollectionViewCell {

    @IBOutlet private weak var movieImage: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var ratingView: StarRatingView!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var favoriteButton: UIButton!
    
    var onFavoriteButtonTapped: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 16
        layer.borderWidth = 4
        layer.borderColor = UIColor(named: "ImageFrameColor")?.cgColor
        favoriteButton.tintColor = .systemRed
    }
    
    func configure(with movie: Movie) {
        titleLabel.text = movie.title
        dateLabel.text = movie.releaseDate.formatDate()
        ratingView.setRating(movie.voteAverage)
        let imageName = movie.isFavorite ? "heart.fill" : "heart"
        let image = UIImage(systemName: imageName)?.withRenderingMode(.alwaysTemplate)
        favoriteButton.setImage(image, for: .normal)
        if let backdropPath = movie.backdropPath {
            Task {
                do {
                    let image = try await ImageLoader.shared.loadImage(
                        from: "https://image.tmdb.org/t/p/w500\(backdropPath)"
                    )
                    if !Task.isCancelled {
                        movieImage.image = image
                    }
                } catch {
                    if !Task.isCancelled {
                        movieImage.image = UIImage(systemName: "photo.fill")
                    }
                }
            }
        }
    }

    @IBAction private func favoriteButtonTapped() {
        onFavoriteButtonTapped?()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        movieImage.image = nil
        titleLabel.text = nil
        dateLabel.text = nil
        favoriteButton.isSelected = false
    }
}
