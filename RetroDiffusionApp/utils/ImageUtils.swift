//
//  ImageUtils.swift
//  RetroDiffusionApp
//
//  Created by Thomas Ricouard on 29/11/25.
//

import UIKit

enum ImageUtils {
    /// Resizes an image to fit within the specified maximum dimension while maintaining aspect ratio.
    /// - Parameters:
    ///   - image: The image to resize
    ///   - maxDimension: The maximum width or height (whichever is larger)
    /// - Returns: The resized image, or the original image if it's already smaller than maxDimension
    static func resizeImage(_ image: UIImage, maxDimension: Int) -> UIImage {
        let size = image.size
        let maxSize = max(size.width, size.height)

        // If image is already smaller than maxDimension, return as-is
        guard maxSize > CGFloat(maxDimension) else {
            return image
        }

        // Calculate new size maintaining aspect ratio
        let scale = CGFloat(maxDimension) / maxSize
        let newWidth = size.width * scale
        let newHeight = size.height * scale
        let newSize = CGSize(width: newWidth, height: newHeight)

        // Resize the image
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        defer { UIGraphicsEndImageContext() }

        image.draw(in: CGRect(origin: .zero, size: newSize))
        return UIGraphicsGetImageFromCurrentImageContext() ?? image
    }

    /// Converts a UIImage to a base64-encoded RGB string (removes transparency).
    /// - Parameter image: The image to convert
    /// - Returns: A base64-encoded string of the RGB image, or nil if conversion fails
    static func imageToBase64RGB(_ image: UIImage) -> String? {
        // Convert to RGB (remove transparency)
        guard let cgImage = image.cgImage else { return nil }

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let width = cgImage.width
        let height = cgImage.height

        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
        ) else {
            return nil
        }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        guard let rgbImage = context.makeImage() else { return nil }
        let uiImage = UIImage(cgImage: rgbImage)

        guard let imageData = uiImage.pngData() else { return nil }
        return imageData.base64EncodedString()
    }
}
