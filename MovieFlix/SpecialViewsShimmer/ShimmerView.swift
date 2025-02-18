//
//  ShimmerView.swift
//  MovieFlix
//
//  Created by Dimitrios Tsoumanis on 18/02/2025.
//

import SwiftUI

struct ShimmerView: View {
    @State private var isAnimating = false

    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.gray.opacity(0.3))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.5))
                    .mask(
                        LinearGradient(gradient: Gradient(colors: [Color.clear, Color.white.opacity(0.6), Color.clear]),
                                       startPoint: .leading,
                                       endPoint: .trailing)
                            .rotationEffect(.degrees(30))
                            .offset(x: isAnimating ? 200 : -200)
                    )
                    .onAppear {
                        withAnimation(Animation.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                            isAnimating.toggle()
                        }
                    }
            )
    }
}
