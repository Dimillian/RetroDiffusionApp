//
//  LibraryDetailView.swift
//  RetroDiffusionApp
//
//  Created by Thomas Ricouard on 29/11/25.
//

import SwiftUI

struct LibraryDetailView: View {
    let libraryImage: LibraryImage
    @Environment(LibraryClient.self) private var libraryClient
    @State private var image: UIImage?
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let image = image {
                GeometryReader { geometry in
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(scale)
                        .offset(offset)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .gesture(
                            SimultaneousGesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        scale = lastScale * value
                                    }
                                    .onEnded { _ in
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                            if scale < 1.0 {
                                                scale = 1.0
                                                offset = .zero
                                            } else if scale > 4.0 {
                                                scale = 4.0
                                            }
                                            lastScale = scale
                                        }
                                    },
                                DragGesture()
                                    .onChanged { value in
                                        offset = CGSize(
                                            width: lastOffset.width + value.translation.width,
                                            height: lastOffset.height + value.translation.height
                                        )
                                    }
                                    .onEnded { _ in
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                            // Snap back if dragged too far
                                            let maxOffset = min(200, geometry.size.width * 0.3)
                                            if abs(offset.width) > maxOffset || abs(offset.height) > maxOffset {
                                                offset = .zero
                                            }
                                            lastOffset = offset
                                        }
                                    }
                            )
                        )
                        .onTapGesture(count: 2) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                if scale > 1.0 {
                                    scale = 1.0
                                    offset = .zero
                                    lastScale = 1.0
                                    lastOffset = .zero
                                } else {
                                    scale = 2.0
                                    lastScale = 2.0
                                }
                            }
                        }
                }
            } else {
                ProgressView()
                    .tint(.white)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if let image = image {
                    ShareLink(
                        item: Image(uiImage: image),
                        preview: SharePreview(
                            "Generated Image",
                            image: Image(uiImage: image)
                        )
                    ) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .toolbarBackground(.black, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            image = await libraryClient.loadImage(for: libraryImage)
        }
    }
}

#Preview {
    LibraryDetailView(
        libraryImage: LibraryImage(
            fileName: "test.png",
            prompt: "A test image",
            model: "rd_fast__default"
        )
    )
    .environment(LibraryClient())
}
