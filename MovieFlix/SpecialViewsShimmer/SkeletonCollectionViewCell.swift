//
//  SkeletonCollectionViewCell.swift
//  MovieFlix
//
//  Created by Dimitrios Tsoumanis on 14/02/2025.
//

import UIKit

class SkeletonCollectionViewCell: UICollectionViewCell {
    private let skeletonView = SkeletonView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSkeleton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSkeleton() {
        contentView.addSubview(skeletonView)
        
        skeletonView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            skeletonView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            skeletonView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            skeletonView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            skeletonView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
}
