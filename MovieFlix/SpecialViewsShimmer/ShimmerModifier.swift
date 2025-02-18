//
//  ShimmerModifier.swift
//  MovieFlix
//
//  Created by Dimitrios Tsoumanis on 18/02/2025.
//

import SwiftUI

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(gradient: Gradient(colors: [
                    Color.white.opacity(0.6),
                    Color.white.opacity(0.3),
                    Color.white.opacity(0.6)
                ]), startPoint: .leading, endPoint: .trailing)
                .mask(content)
                .opacity(0.8)
                .offset(x: phase)
                .animation(Animation.linear(duration: 1.5).repeatForever(autoreverses: true), value: phase)
            )
            .onAppear {
                phase = 50
            }
    }
}
