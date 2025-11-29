//
//  GenerateView.swift
//  RetroDiffusionApp
//
//  Created by Thomas Ricouard on 29/11/25.
//

import SwiftUI

struct GenerateView: View {
    @Environment(Networking.self) private var networking

    @State private var selectedModel: RetroDiffusionModel = .rdFastDefault
    @State private var prompt: String = ""
    @State private var generatedImage: UIImage?
    @State private var showingError = false
    @State private var width: Int = 256
    @State private var height: Int = 256
    @State private var cost: Double?
    @State private var checkingCost = false
    @State private var showingSaveSuccess = false
    @State private var showingSaveError = false
    @State private var saveErrorMessage: String?
    @State private var costCheckTask: Task<Void, Never>?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    ModelPickerView(selectedModel: $selectedModel)
                    PromptInputView(prompt: $prompt)
                    SizeControlsView(width: $width, height: $height)

                    if !prompt.isEmpty {
                        CostPreviewView(cost: cost, checkingCost: checkingCost)

                        PrimaryButton(
                            title: "Generate Image",
                            icon: "sparkles",
                            action: generateImage,
                            isDisabled: networking.isLoading
                        )
                    }

                    if networking.isLoading {
                        ProgressView("Generating image...")
                            .padding()
                    }

                    if let generatedImage = generatedImage {
                        VStack(spacing: 16) {
                            ImageDisplayView(
                                title: "Generated Image",
                                image: generatedImage,
                                maxHeight: 400
                            )

                            SaveImageButton(
                                image: generatedImage,
                                onSaveSuccess: { showingSaveSuccess = true },
                                onSaveError: { error in
                                    saveErrorMessage = error
                                    showingSaveError = true
                                }
                            )
                        }
                    } else if !networking.isLoading && prompt.isEmpty {
                        EmptyStateView(
                            icon: "sparkles",
                            message: "Enter a prompt and select a model style to generate pixel art"
                        )
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Generate")
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
            .onChange(of: prompt) { oldValue, newValue in
                if !newValue.isEmpty {
                    debouncedCheckCost()
                } else {
                    costCheckTask?.cancel()
                    cost = nil
                    checkingCost = false
                }
            }
            .onChange(of: selectedModel) { oldValue, newValue in
                if !prompt.isEmpty {
                    debouncedCheckCost()
                }
            }
            .onChange(of: width) { oldValue, newValue in
                if !prompt.isEmpty {
                    debouncedCheckCost()
                }
            }
            .onChange(of: height) { oldValue, newValue in
                if !prompt.isEmpty {
                    debouncedCheckCost()
                }
            }
            .onDisappear {
                costCheckTask?.cancel()
            }
        }
    }

    private func debouncedCheckCost() {
        costCheckTask?.cancel()

        costCheckTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000)

            guard !Task.isCancelled else { return }
            guard !prompt.isEmpty else { return }

            await checkCost()
        }
    }

    private func checkCost() async {
        guard !prompt.isEmpty else { return }

        await MainActor.run {
            checkingCost = true
        }

        do {
            let costValue = try await networking.checkGenerateCost(
                prompt: prompt,
                style: selectedModel,
                width: width,
                height: height
            )

            guard !Task.isCancelled else { return }

            await MainActor.run {
                cost = costValue
                checkingCost = false
            }
        } catch {
            guard !Task.isCancelled else { return }

            await MainActor.run {
                checkingCost = false
                print("Failed to check cost: \(error)")
            }
        }
    }

    private func generateImage() {
        guard !prompt.isEmpty else { return }

        Task {
            do {
                let result = try await networking.generateImage(
                    prompt: prompt,
                    style: selectedModel,
                    width: width,
                    height: height
                )
                await MainActor.run {
                    generatedImage = result
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
    GenerateView()
        .environment(Networking())
}
