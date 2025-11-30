//
//  GenerateView.swift
//  RetroDiffusionApp
//
//  Created by Thomas Ricouard on 29/11/25.
//

import SwiftUI

struct GenerateView: View {
    @Environment(Networking.self) private var networking
    @Environment(LibraryManager.self) private var libraryManager
    @Environment(GenerationQueue.self) private var generationQueue

    @State private var selectedCategory: ModelCategory = .rdFast
    @State private var selectedModel: RetroDiffusionModel = .rdFastDefault
    @State private var prompt: String = ""
    @State private var width: Int = 256
    @State private var height: Int = 256
    @State private var cost: Double?
    @State private var checkingCost = false
    @State private var costCheckTask: Task<Void, Never>?

    private var availableModels: [RetroDiffusionModel] {
        RetroDiffusionModel.models(for: selectedCategory)
    }

    private var minSize: Int {
        Constants.SizeConstraints.minSize
    }

    private var maxSize: Int {
        Constants.SizeConstraints.maxSize
    }

    private func clampSize(_ value: Int) -> Int {
        max(minSize, min(value, maxSize))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Model") {
                    Picker("Model Category", selection: $selectedCategory) {
                        ForEach(ModelCategory.allCases) { category in
                            Text(category.displayName).tag(category)
                        }
                    }

                    Picker("Model Style", selection: $selectedModel) {
                        ForEach(availableModels) { model in
                            Text(model.shortDisplayName).tag(model)
                        }
                    }
                }

                Section("Prompt") {
                    TextField("Enter your prompt...", text: $prompt, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Size") {
                    LabeledContent("Width") {
                        TextField("256", value: $width, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }

                    LabeledContent("Height") {
                        TextField("256", value: $height, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }

                    LabeledContent("Range") {
                        Text("\(minSize)-\(maxSize)")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }

                if !prompt.isEmpty {
                    Section {
                        if let cost = cost {
                            HStack {
                                Image(systemName: "creditcard")
                                    .foregroundColor(.secondary)
                                Text("Cost: \(cost, specifier: "%.2f") credits")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        } else if checkingCost {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("Checking cost...")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }

                        Button(action: generateImage) {
                            HStack {
                                Image(systemName: "sparkles")
                                Text("Generate Image")
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }

                if !prompt.isEmpty {
                    Section {
                        VStack(spacing: 20) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 60))
                                .foregroundColor(.secondary)

                            Text("Enter a prompt and select a model style to generate pixel art")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    }
                }
            }
            .navigationTitle("Generate")
            .onChange(of: prompt) { oldValue, newValue in
                if !newValue.isEmpty {
                    debouncedCheckCost()
                } else {
                    costCheckTask?.cancel()
                    cost = nil
                    checkingCost = false
                }
            }
            .onChange(of: selectedCategory) { oldValue, newValue in
                let models = RetroDiffusionModel.models(for: newValue)
                if let firstModel = models.first {
                    selectedModel = firstModel
                }
                if !prompt.isEmpty {
                    debouncedCheckCost()
                }
            }
            .onChange(of: selectedModel) { oldValue, newValue in
                if !prompt.isEmpty {
                    debouncedCheckCost()
                }
            }
            .onChange(of: width) { oldValue, newValue in
                let clampedValue = clampSize(newValue)
                if clampedValue != newValue {
                    width = clampedValue
                }
                if !prompt.isEmpty {
                    debouncedCheckCost()
                }
            }
            .onChange(of: height) { oldValue, newValue in
                let clampedValue = clampSize(newValue)
                if clampedValue != newValue {
                    height = clampedValue
                }
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

        let validWidth = clampSize(width)
        let validHeight = clampSize(height)

        await MainActor.run {
            checkingCost = true
        }

        do {
            let costValue = try await networking.checkGenerateCost(
                prompt: prompt,
                style: selectedModel,
                width: validWidth,
                height: validHeight
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

        let validWidth = clampSize(width)
        let validHeight = clampSize(height)

        if validWidth != width || validHeight != height {
            width = validWidth
            height = validHeight
        }

        generationQueue.enqueueGenerate(
            prompt: prompt,
            model: selectedModel,
            width: validWidth,
            height: validHeight
        )

        prompt = ""
        cost = nil
    }
}

#Preview {
    GenerateView()
        .environment(Networking())
        .environment(LibraryManager())
        .environment(GenerationQueue())
}
