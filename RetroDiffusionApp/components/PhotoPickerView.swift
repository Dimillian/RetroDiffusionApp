//
//  PhotoPickerView.swift
//  RetroDiffusionApp
//
//  Created by Thomas Ricouard on 29/11/25.
//

import SwiftUI
import PhotosUI

struct PhotoPickerView: View {
    @Binding var selectedItem: PhotosPickerItem?

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "photo.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text("Select an image from your photo library to pixelate it")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            PhotosPicker(
                selection: $selectedItem,
                matching: .images
            ) {
                Label("Choose Photo", systemImage: "photo.on.rectangle")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 60)
    }
}

#Preview {
    PhotoPickerView(selectedItem: .constant(nil))
}
