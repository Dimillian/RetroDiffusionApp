//
//  EmptyStateView.swift
//  RetroDiffusionApp
//
//  Created by Thomas Ricouard on 29/11/25.
//

import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let message: String
    let action: (() -> Void)?
    let actionTitle: String?

    init(
        icon: String,
        message: String,
        action: (() -> Void)? = nil,
        actionTitle: String? = nil
    ) {
        self.icon = icon
        self.message = message
        self.action = action
        self.actionTitle = actionTitle
    }

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            if let action = action, let actionTitle = actionTitle {
                Button(action: action) {
                    Text(actionTitle)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 60)
    }
}

#Preview {
    EmptyStateView(
        icon: "photo.badge.plus",
        message: "Select an image from your photo library",
        action: {},
        actionTitle: "Choose Photo"
    )
}
