//
//  ImageLoader.swift
//  MovieFlix
//
//  Created by Dimitrios Tsoumanis on 12/02/2025.
//

import UIKit

actor ImageLoader {
    static let shared = ImageLoader()
    
    private var imageCache = NSCache<NSString, UIImage>()
    private var ongoingTasks: [String: Task<UIImage, Error>] = [:]
    
    func loadImage(from urlString: String) async throws -> UIImage {
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            return cachedImage
        }
        
        if let existingTask = ongoingTasks[urlString] {
            return try await existingTask.value
        }
        
        let task = Task<UIImage, Error> {
            guard let url = URL(string: urlString) else {
                throw URLError(.badURL)
            }
            
            let data = try await URLSession.shared.data(from: url).0
            guard let image = UIImage(data: data) else {
                throw URLError(.cannotDecodeContentData)
            }
            
            imageCache.setObject(image, forKey: urlString as NSString)
            return image
        }
        
        ongoingTasks[urlString] = task
        
        do {
            let image = try await task.value
            ongoingTasks[urlString] = nil
            return image
        } catch {
            ongoingTasks[urlString] = nil
            throw error
        }
    }
    
    func prefetchImage(from urlString: String) {
        Task {
            try? await loadImage(from: urlString)
        }
    }
    
    func cancelPrefetch(for urlString: String) {
        ongoingTasks[urlString]?.cancel()
        ongoingTasks[urlString] = nil
    }
    
    func clearCache() {
        imageCache.removeAllObjects()
        for task in ongoingTasks.values {
            task.cancel()
        }
        ongoingTasks.removeAll()
    }
}
