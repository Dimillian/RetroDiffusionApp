//
//  ImageDisplayView.swift
//  RetroDiffusionApp
//
//  Created by Thomas Ricouard on 29/11/25.
//

import SwiftUI

struct ImageDisplayView: View {
    let title: String
    let image: UIImage
    let maxHeight: CGFloat

    var body: some View {
        VStack(spacing: 16) {
            Text(title)
                .font(.headline)

            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: maxHeight)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(radius: 4)
        }
        .padding()
    }
}

#Preview {
    ImageDisplayView(
        title: "Preview Image",
        image: UIImage(systemName: "photo")!,
        maxHeight: 300
    )
}
