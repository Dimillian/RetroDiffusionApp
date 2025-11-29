//
//  ImageSaver.swift
//  RetroDiffusionApp
//
//  Created by Thomas Ricouard on 29/11/25.
//

import UIKit
import Photos

enum ImageSaver {
    enum SaveError: LocalizedError {
        case unauthorized
        case saveFailed(String)

        var errorDescription: String? {
            switch self {
            case .unauthorized:
                return "Photo library access is required to save images. Please enable it in Settings."
            case .saveFailed(let message):
                return message
            }
        }
    }

    enum SaveResult {
        case success
        case failure(SaveError)
    }

    static func save(image: UIImage, completion: @escaping (SaveResult) -> Void) {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            guard status == .authorized || status == .limited else {
                completion(.failure(.unauthorized))
                return
            }

            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }) { success, error in
                if success {
                    completion(.success)
                } else {
                    let errorMessage = error?.localizedDescription ?? "Failed to save image"
                    completion(.failure(.saveFailed(errorMessage)))
                }
            }
        }
    }
}
