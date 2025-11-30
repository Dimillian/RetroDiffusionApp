//
//  ImageUtils.swift
//  RetroDiffusionApp
//
//  Created by Thomas Ricouard on 29/11/25.
//

import UIKit

struct ImageUtils {
  /// Resizes an image to fit within the specified maximum dimension while maintaining aspect ratio.
  /// Marked @concurrent to offload to the global executor while inheriting caller cancellation.
  @concurrent
  func resizeImage(_ image: UIImage, maxDimension: Int) async -> UIImage {
    let size = image.size
    let maxSize = max(size.width, size.height)

    guard maxSize > CGFloat(maxDimension) else {
      return image
    }

    let scale = CGFloat(maxDimension) / maxSize
    let newSize = CGSize(width: size.width * scale, height: size.height * scale)

    let format = UIGraphicsImageRendererFormat()
    format.scale = 1.0

    let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
    return renderer.image { _ in
      image.draw(in: CGRect(origin: .zero, size: newSize))
    }
  }

  /// Converts a UIImage to a base64-encoded RGB string (removes transparency).
  @concurrent
  func imageToBase64RGB(_ image: UIImage) async -> String? {
    guard let cgImage = image.cgImage else { return nil }

    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let width = cgImage.width
    let height = cgImage.height
    let bytesPerRow = width * 4

    guard
      let context = CGContext(
        data: nil,
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: bytesPerRow,
        space: colorSpace,
        bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
      )
    else {
      return nil
    }

    context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

    guard let rgbImage = context.makeImage() else { return nil }
    let uiImage = UIImage(cgImage: rgbImage)

    guard let imageData = uiImage.pngData() else { return nil }
    return imageData.base64EncodedString()
  }
}
