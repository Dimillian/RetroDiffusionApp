//
//  SizeControlsView.swift
//  RetroDiffusionApp
//
//  Created by Thomas Ricouard on 29/11/25.
//

import SwiftUI

struct SizeControlsView: View {
    @Binding var width: Int
    @Binding var height: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Size")
                .font(.headline)

            HStack(spacing: 16) {
                VStack(alignment: .leading) {
                    Text("Width")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("256", value: $width, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                }

                VStack(alignment: .leading) {
                    Text("Height")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("256", value: $height, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                }
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    SizeControlsView(width: .constant(256), height: .constant(256))
}
