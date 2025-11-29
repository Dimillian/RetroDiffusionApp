//
//  PromptInputView.swift
//  RetroDiffusionApp
//
//  Created by Thomas Ricouard on 29/11/25.
//

import SwiftUI

struct PromptInputView: View {
    @Binding var prompt: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Prompt")
                .font(.headline)

            TextField("Enter your prompt...", text: $prompt, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(3...6)
        }
        .padding(.horizontal)
    }
}

#Preview {
    PromptInputView(prompt: .constant(""))
}
