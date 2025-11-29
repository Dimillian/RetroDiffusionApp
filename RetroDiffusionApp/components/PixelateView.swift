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

    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var pixelatedImage: UIImage?
    @State private var showingError = false
    @State private var cost: Double?
    @State private var checkingCost = false
    @State private var showingSaveSuccess = false
    @State private var showingSaveError = false
    @State private var saveErrorMessage: String?

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

                        if let pixelatedImage = pixelatedImage {
                            VStack(spacing: 16) {
                                ImageDisplayView(
                                    title: "Pixelated Image",
                                    image: pixelatedImage,
                                    maxHeight: 300
                                )

                                SaveImageButton(
                                    image: pixelatedImage,
                                    onSaveSuccess: { showingSaveSuccess = true },
                                    onSaveError: { error in
                                        saveErrorMessage = error
                                        showingSaveError = true
                                    }
                                )
                            }
                        }

                        CostPreviewView(cost: cost, checkingCost: checkingCost)

                        if networking.isLoading {
                            ProgressView("Pixelating image...")
                                .padding()
                        } else if pixelatedImage == nil {
                            PrimaryButton(
                                title: "Pixelate Image",
                                icon: "sparkles",
                                action: pixelateImage
                            )
                        }
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
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(networking.errorMessage ?? "An unknown error occurred")
            }
            .alert("Saved!", isPresented: $showingSaveSuccess) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Image saved to your photo library")
            }
            .alert("Save Failed", isPresented: $showingSaveError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(saveErrorMessage ?? "Failed to save image")
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
            pixelatedImage = nil
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

        Task {
            do {
                let result = try await networking.pixelateImage(image)
                await MainActor.run {
                    pixelatedImage = result
                }
            } catch {
                await MainActor.run {
                    networking.errorMessage = error.localizedDescription
                    showingError = true
                }
            }
        }
    }
}

#Preview {
    PixelateView()
        .environment(Networking())
}
