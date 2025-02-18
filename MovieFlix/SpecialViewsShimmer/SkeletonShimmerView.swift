//
//  SkeletonShimmerView.swift
//  MovieFlix
//
//  Created by Dimitrios Tsoumanis on 18/02/2025.
//

import SwiftUI

struct SkeletonShimmerView<Content: View>: View {
    let isLoading: Bool
    let content: () -> Content

    var body: some View {
        ZStack {
            if isLoading {
                content()
                    .redacted(reason: .placeholder)
                    .modifier(ShimmerModifier())
            } else {
                content()
            }
        }
        .animation(.easeInOut, value: isLoading)
    }
}
