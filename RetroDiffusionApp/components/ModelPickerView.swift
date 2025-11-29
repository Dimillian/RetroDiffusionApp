//
//  ModelPickerView.swift
//  RetroDiffusionApp
//
//  Created by Thomas Ricouard on 29/11/25.
//

import SwiftUI

struct ModelPickerView: View {
    @Binding var selectedModel: RetroDiffusionModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Model Style")
                .font(.headline)

            Picker("Model", selection: $selectedModel) {
                ForEach(RetroDiffusionModel.allCases) { model in
                    Text(model.displayName).tag(model)
                }
            }
            .pickerStyle(.menu)
        }
        .padding(.horizontal)
    }
}

#Preview {
    ModelPickerView(selectedModel: .constant(.rdFastDefault))
}
