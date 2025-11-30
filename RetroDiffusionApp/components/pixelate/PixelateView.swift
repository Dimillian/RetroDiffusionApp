//
//  PixelateView.swift
//  RetroDiffusionApp
//
//  Created by Thomas Ricouard on 29/11/25.
//

import SwiftUI
import PhotosUI

struct PixelateView: View {
    @Environment(Networking.self) private var networking
    @Environment(LibraryManager.self) private var libraryManager
    @Environment(GenerationQueue.self) private var generationQueue

    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var cost: Double?
    @State private var checkingCost = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if let selectedImage = selectedImage {
                        ImageDisplayView(
                            title: "Original Image",
                            image: selectedImage,
                            maxHeight: 300
                        )

                        CostPreviewView(cost: cost, checkingCost: checkingCost)

                        PrimaryButton(
                            title: "Pixelate Image",
                            icon: "sparkles",
                            action: pixelateImage
                        )

                        Button(action: clearSelection) {
                            Label("Select another photo", systemImage: "photo.badge.plus")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.horizontal)
                    } else {
                        PhotoPickerView(selectedItem: $selectedItem)
                    }
                }
            }
            .navigationTitle("Pixelate")
            .onChange(of: selectedItem) { oldValue, newValue in
                Task {
                    await loadImage(from: newValue)
                }
            }
        }
    }

    private func loadImage(from item: PhotosPickerItem?) async {
        guard let item = item else { return }

        guard let data = try? await item.loadTransferable(type: Data.self),
              let image = UIImage(data: data) else {
            return
        }

        await MainActor.run {
            selectedImage = image
            cost = nil
        }

        await checkCost(for: image)
    }

    private func checkCost(for image: UIImage) async {
        await MainActor.run {
            checkingCost = true
        }

        do {
            let costValue = try await networking.checkPixelateCost(image)
            await MainActor.run {
                cost = costValue
                checkingCost = false
            }
        } catch {
            await MainActor.run {
                checkingCost = false
                print("Failed to check cost: \(error)")
            }
        }
    }

    private func pixelateImage() {
        guard let image = selectedImage else { return }

        generationQueue.enqueuePixelate(image: image)

        selectedImage = nil
        selectedItem = nil
        cost = nil
    }

    private func clearSelection() {
        selectedImage = nil
        selectedItem = nil
        cost = nil
        checkingCost = false
    }
}

#Preview {
    PixelateView()
        .environment(Networking())
        .environment(LibraryManager())
        .environment(GenerationQueue())
}
