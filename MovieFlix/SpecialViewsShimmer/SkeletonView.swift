//
//  SkeletonView.swift
//  MovieFlix
//
//  Created by Dimitrios Tsoumanis on 14/02/2025.
//

import SwiftUI
import UIKit

class SkeletonView: UIView {
    private let shimmerLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupShimmer()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupShimmer() {
        setShimmerColor(.lightGray)
        shimmerLayer.startPoint = CGPoint(x: 0, y: 0.5)
        shimmerLayer.endPoint = CGPoint(x: 1, y: 0.5)
        shimmerLayer.locations = [0.0, 0.2, 0.5, 0.8, 1.0]
        layer.addSublayer(shimmerLayer)
    }

    func setShimmerColor(_ color: UIColor) {
        shimmerLayer.colors = [
            color.withAlphaComponent(0.3).cgColor,
            color.withAlphaComponent(0.5).cgColor,
            color.withAlphaComponent(0.8).cgColor,
            color.withAlphaComponent(0.5).cgColor,
            color.withAlphaComponent(0.3).cgColor
        ]
    }

    func setAnimationDuration(_ duration: Double) {
        shimmerLayer.removeAllAnimations()
        startWaveAnimation(duration: duration)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        shimmerLayer.frame = bounds
        startWaveAnimation()
    }

    private func startWaveAnimation(duration: Double = 1.5) {
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [0.0, 0.1, 0.5, 0.9, 1.0]
        animation.toValue = [0.0, 0.3, 0.5, 0.7, 1.0]
        animation.duration = duration
        animation.autoreverses = true
        animation.repeatCount = .infinity
        shimmerLayer.add(animation, forKey: "waveAnimation")
    }
}
