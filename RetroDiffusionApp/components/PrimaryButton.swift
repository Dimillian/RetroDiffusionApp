//
//  PrimaryButton.swift
//  RetroDiffusionApp
//
//  Created by Thomas Ricouard on 29/11/25.
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    var isDisabled: Bool = false

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(isDisabled)
        .padding(.horizontal)
    }
}

#Preview {
    VStack(spacing: 16) {
        PrimaryButton(title: "Generate Image", icon: "sparkles", action: {})
        PrimaryButton(title: "Pixelate Image", icon: "sparkles", action: {}, isDisabled: true)
    }
}
