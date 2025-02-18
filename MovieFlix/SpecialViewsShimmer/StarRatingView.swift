//
//  StarRatingView.swift
//  MovieFlix
//
//  Created by Dimitrios Tsoumanis on 12/02/2025.
//

import SwiftUI
import UIKit

class StarRatingView: UIView {
    private let maxStars = 5
    private var starStackView: UIStackView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        starStackView = UIStackView()
        starStackView.axis = .horizontal
        starStackView.distribution = .fillEqually
        starStackView.spacing = 4
        addSubview(starStackView)
        
        starStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            starStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            starStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            starStackView.topAnchor.constraint(equalTo: topAnchor),
            starStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        for _ in 0..<maxStars {
            let starImageView = UIImageView()
            starImageView.contentMode = .scaleAspectFit
            starImageView.tintColor = .lightGray
            starStackView.addArrangedSubview(starImageView)
        }
    }
    
    func setRating(_ rating: Double) {
        let filledStars = Int(rating / 2)
        let hasHalfStar = (rating.truncatingRemainder(dividingBy: 2) >= 1)
        
        for (index, starImageView) in starStackView.arrangedSubviews.enumerated() {
            guard let starImageView = starImageView as? UIImageView else { continue }
            
            if index < filledStars {
                starImageView.image = UIImage(systemName: "star.fill")
                starImageView.tintColor = .systemYellow
            } else if index == filledStars && hasHalfStar {
                starImageView.image = UIImage(systemName: "star.leadinghalf.filled")
                starImageView.tintColor = .systemYellow
            } else {
                starImageView.image = UIImage(systemName: "star")
                starImageView.tintColor = .lightGray
            }
        }
    }
}

struct StarRatingViewWrapper: UIViewRepresentable {
    var rating: Double
    
    func makeUIView(context: Context) -> StarRatingView {
        let starView = StarRatingView()
        starView.setRating(rating)
        return starView
    }
    
    func updateUIView(_ uiView: StarRatingView, context: Context) {
        uiView.setRating(rating)
    }
}
