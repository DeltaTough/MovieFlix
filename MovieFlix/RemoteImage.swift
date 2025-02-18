//
//  RemoteImage.swift
//  MovieFlix
//
//  Created by Dimitrios Tsoumanis on 18/02/2025.
//

import SwiftUI

struct RemoteImage<Content: View, Placeholder: View>: View {
    @StateObject private var imageState = ImageState()
    let url: String
    let content: (UIImage) -> Content
    
    init(
        url: String,
        @ViewBuilder content: @escaping (UIImage) -> Content) {
        self.url = url
        self.content = content
    }
    
    var body: some View {
        Group {
            if let image = imageState.image {
                content(image)
            }
        }
        .onAppear {
            loadImage()
        }
        .onChange(of: url) { newUrl in
            loadImage()
        }
    }
    
    private func loadImage() {
        Task {
            do {
                let image = try await ImageLoader.shared.loadImage(from: url)
                imageState.setImage(image)
            } catch {
                print("Error loading image: \(error)")
            }
        }
    }
}

@MainActor
class ImageState: ObservableObject {
    @Published var image: UIImage?
    
    func setImage(_ image: UIImage) {
        self.image = image
    }
}
