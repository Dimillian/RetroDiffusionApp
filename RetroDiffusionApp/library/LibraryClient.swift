//
//  LibraryClient.swift
//  RetroDiffusionApp
//
//  Created by Thomas Ricouard on 29/11/25.
//

import Foundation
import UIKit
import Observation

@MainActor
@Observable
final class LibraryClient {
    private let store: LibraryStore
    private let pageSize: Int
    private var hasMore = true
    private var isLoading = false
    private let imageCache = NSCache<NSString, UIImage>()

    private(set) var images: [LibraryImage] = []

    init(pageSize: Int = 50) {
        guard let store = LibraryStore() else {
            fatalError("Failed to initialize LibraryStore.")
        }
        self.store = store
        self.pageSize = pageSize
    }

    func loadInitial() async {
        images = []
        hasMore = true
        await loadNextPage()
    }

    func loadNextPage() async {
        guard hasMore, !isLoading else { return }
        isLoading = true
        let page = await store.fetchPage(offset: images.count, limit: pageSize)
        images.append(contentsOf: page)
        hasMore = page.count == pageSize
        isLoading = false
    }

    func save(
        image: UIImage,
        prompt: String? = nil,
        model: String? = nil,
        width: Int? = nil,
        height: Int? = nil
    ) async {
        guard let data = image.pngData() else { return }

        do {
            let saved = try await store.save(
                imageData: data,
                prompt: prompt,
                model: model,
                width: width,
                height: height
            )
            images.insert(saved, at: 0)
            imageCache.setObject(image, forKey: saved.id.uuidString as NSString)
        } catch {
            print("Failed to save image: \(error)")
        }
    }

    func delete(_ libraryImage: LibraryImage) async {
        await store.delete(id: libraryImage.id)
        images.removeAll { $0.id == libraryImage.id }
        imageCache.removeObject(forKey: libraryImage.id.uuidString as NSString)
    }

    func loadImage(for libraryImage: LibraryImage) async -> UIImage? {
        let key = libraryImage.id.uuidString as NSString
        if let cached = imageCache.object(forKey: key) {
            return cached
        }

        guard let data = await store.imageData(forFileName: libraryImage.fileName),
              let image = UIImage(data: data) else {
            return nil
        }

        imageCache.setObject(image, forKey: key)
        return image
    }
}
