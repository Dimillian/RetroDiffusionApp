//
//  SaveImageButton.swift
//  RetroDiffusionApp
//
//  Created by Thomas Ricouard on 29/11/25.
//

import SwiftUI

struct SaveImageButton: View {
    let image: UIImage
    let onSaveSuccess: () -> Void
    let onSaveError: (String) -> Void

    var body: some View {
        Button(action: { saveImage() }) {
            Label("Save to Photos", systemImage: "square.and.arrow.down")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor.opacity(0.1))
                .foregroundColor(.accentColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal)
    }

    private func saveImage() {
        ImageSaver.save(image: image) { result in
            switch result {
            case .success:
                onSaveSuccess()
            case .failure(let error):
                onSaveError(error.localizedDescription)
            }
        }
    }
}

#Preview {
    SaveImageButton(
        image: UIImage(systemName: "photo")!,
        onSaveSuccess: {},
        onSaveError: { _ in }
    )
}
