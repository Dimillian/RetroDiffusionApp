//
//  LibraryThumbnailView.swift
//  RetroDiffusionApp
//
//  Created by Thomas Ricouard on 29/11/25.
//

import SwiftUI

struct LibraryThumbnailView: View {
    @Environment(LibraryClient.self) private var libraryClient
    let libraryImage: LibraryImage
    var onImageLoaded: (UIImage?) -> Void = { _ in }
    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipped()
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 100, height: 100)
                    .overlay {
                        ProgressView()
                    }
            }
        }
        .task {
            let loaded = await libraryClient.loadImage(for: libraryImage)
            await MainActor.run {
                image = loaded
                onImageLoaded(loaded)
            }
        }
    }
}
