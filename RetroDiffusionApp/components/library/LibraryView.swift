//
//  LibraryView.swift
//  RetroDiffusionApp
//
//  Created by Thomas Ricouard on 29/11/25.
//

import SwiftUI

struct LibraryView: View {
    @Environment(LibraryClient.self) private var libraryClient
    @Environment(GenerationQueue.self) private var generationQueue
    @Namespace private var namespace
    @State private var thumbnailCache: [UUID: UIImage] = [:]

    private let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 2)
    ]

    private var hasAnyContent: Bool {
        !generationQueue.inProgressTasks.isEmpty ||
        !generationQueue.pendingTasks.isEmpty ||
        !libraryClient.images.isEmpty
    }

    var body: some View {
        NavigationStack {
            Group {
                if !hasAnyContent {
                    VStack(spacing: 20) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)

                        Text("No images yet")
                            .font(.title2)
                            .foregroundColor(.secondary)

                        Text("Generated images will appear here")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            if !generationQueue.inProgressTasks.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("In Progress")
                                        .font(.headline)
                                        .padding(.horizontal, 4)

                                    LazyVGrid(columns: columns, spacing: 2) {
                                        ForEach(generationQueue.inProgressTasks) { task in
                                            LibraryTaskView(task: task)
                                        }
                                    }
                                    .padding(.horizontal, 2)
                                }
                            }

                            if !generationQueue.pendingTasks.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Pending")
                                        .font(.headline)
                                        .padding(.horizontal, 4)

                                    LazyVGrid(columns: columns, spacing: 2) {
                                        ForEach(generationQueue.pendingTasks) { task in
                                            LibraryTaskView(task: task)
                                        }
                                    }
                                    .padding(.horizontal, 2)
                                }
                            }

                            if !libraryClient.images.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Library")
                                        .font(.headline)
                                        .padding(.horizontal, 4)

                                    LazyVGrid(columns: columns, spacing: 2) {
                                        ForEach(libraryClient.images) { libraryImage in
                                            NavigationLink {
                                                LibraryDetailView(libraryImage: libraryImage)
                                                    .navigationTransition(.zoom(sourceID: libraryImage.id.uuidString, in: namespace))
                                            } label: {
                                                LibraryThumbnailView(
                                                    libraryImage: libraryImage,
                                                    onImageLoaded: { image in
                                                        if let image {
                                                            thumbnailCache[libraryImage.id] = image
                                                        }
                                                    }
                                                )
                                                    .matchedTransitionSource(id: libraryImage.id.uuidString, in: namespace)
                                                    .onAppear {
                                                        loadNextPageIfNeeded(current: libraryImage)
                                                    }
                                            }
                                            .contextMenu {
                                                if let image = thumbnailCache[libraryImage.id] {
                                                    ShareLink(
                                                        item: Image(uiImage: image),
                                                        preview: SharePreview("Image", image: Image(uiImage: image))
                                                    ) {
                                                        Label("Share", systemImage: "square.and.arrow.up")
                                                    }
                                                }

                                                Button(role: .destructive) {
                                                    Task {
                                                        await libraryClient.delete(libraryImage)
                                                    }
                                                } label: {
                                                    Label("Delete", systemImage: "trash")
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 2)
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Library")
            .task {
                await libraryClient.loadInitial()
            }
        }
    }

    private func loadNextPageIfNeeded(current: LibraryImage) {
        guard let index = libraryClient.images.firstIndex(where: { $0.id == current.id }) else {
            return
        }

        let threshold = libraryClient.images.count - 5
        if index >= threshold {
            Task {
                await libraryClient.loadNextPage()
            }
        }
    }
}

#Preview {
    LibraryView()
        .environment(LibraryClient())
        .environment(GenerationQueue())
}
