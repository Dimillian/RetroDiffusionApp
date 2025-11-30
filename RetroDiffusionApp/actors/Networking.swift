//
//  Networking.swift
//  RetroDiffusionApp
//
//  Created by Thomas Ricouard on 29/11/25.
//

import Foundation
import UIKit

actor Networking {
  private let baseURL = "https://api.retrodiffusion.ai/v1"
  private var apiKey: String
  private let imageUtils = ImageUtils()

  init() {
    guard let resolvedKey = Self.resolveAPIKey() else {
      fatalError(
        "API_KEY not found. Please set a custom API key in Settings or create Config.plist with API_KEY."
      )
    }
    self.apiKey = resolvedKey
  }

  func updateAPIKey(_ newKey: String?) {
    if let newKey = newKey, !newKey.isEmpty {
      self.apiKey = newKey
      return
    }

    if let resolvedKey = Self.resolveAPIKey() {
      self.apiKey = resolvedKey
    } else {
      self.apiKey = ""
    }
  }

  /// Resolves the API key by checking UserDefaults first, then falling back to Config.plist
  private static func resolveAPIKey() -> String? {
    if let customKey = UserDefaults.standard.string(forKey: "custom_api_key"),
      !customKey.isEmpty
    {
      return customKey
    }

    return loadAPIKeyFromConfig()
  }

  private static func loadAPIKeyFromConfig() -> String? {
    guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
      let plist = NSDictionary(contentsOfFile: path),
      let apiKey = plist["API_KEY"] as? String
    else {
      return nil
    }
    return apiKey
  }

  func pixelateImage(_ image: UIImage) async throws -> UIImage {

    print("🔵 [Pixelate] Starting pixelation")
    print("🔵 [Pixelate] Original image size: \(image.size.width)x\(image.size.height)")

    // Resize image to fit within API limits (max 256x256)
        let resizedImage = await ImageUtils().resizeImage(image, maxDimension: 256)
    print("🔵 [Pixelate] Resized image size: \(resizedImage.size.width)x\(resizedImage.size.height)")

    // Convert UIImage to base64 RGB (no transparency)
        guard let base64Image = await ImageUtils().imageToBase64RGB(resizedImage) else {
            print("❌ [Pixelate] Failed to convert image to base64")
            throw NetworkingError.imageConversionFailed
        }

    let base64Length = base64Image.count

    print(
      "🔵 [Pixelate] Base64 image length: \(base64Length) characters (~\(base64Length * 3 / 4) bytes)"
    )

    let request = InferenceRequest(
      width: Int(resizedImage.size.width),
      height: Int(resizedImage.size.height),
      prompt: "",
      numImages: 1,
      promptStyle: "rd_pro__pixelate",
      inputImage: base64Image,
      checkCost: false
    )

    print(
      "🔵 [Pixelate] Request: width=\(request.width), height=\(request.height), style=\(request.promptStyle ?? "nil")"
    )

    do {
      let response: InferenceResponse = try await performRequest(
        endpoint: "/inferences",
        request: request
      )

      print("🔵 [Pixelate] Response received: \(response.base64Images.count) image(s)")
      print("🔵 [Pixelate] Credit cost: \(response.creditCost)")
      if let remainingCredits = response.remainingCredits {
        print("🔵 [Pixelate] Remaining credits: \(remainingCredits)")
      }
      if let balanceCost = response.balanceCost {
        print("🔵 [Pixelate] Balance cost: \(balanceCost)")
      }

      guard let firstImage = response.base64Images.first else {
        print("❌ [Pixelate] No images in response")
        throw NetworkingError.imageDecodingFailed
      }

      print("🔵 [Pixelate] First image base64 length: \(firstImage.count) characters")

      guard let imageData = Data(base64Encoded: firstImage) else {
        print("❌ [Pixelate] Failed to decode base64 to Data")
        throw NetworkingError.imageDecodingFailed
      }

      print("🔵 [Pixelate] Decoded image data size: \(imageData.count) bytes")

      guard let resultImage = UIImage(data: imageData) else {
        print("❌ [Pixelate] Failed to create UIImage from data")
        throw NetworkingError.imageDecodingFailed
      }

      print(
        "✅ [Pixelate] Success! Result image size: \(resultImage.size.width)x\(resultImage.size.height)"
      )
      return resultImage
    } catch {
      print("❌ [Pixelate] Error: \(error)")
      if let networkingError = error as? NetworkingError {
        print("❌ [Pixelate] Networking error: \(networkingError.localizedDescription)")
      }
      throw error
    }
  }

  func generateImage(
    prompt: String,
    style: RetroDiffusionModel,
    width: Int = 256,
    height: Int = 256
  ) async throws -> UIImage {

    let request = InferenceRequest(
      width: width,
      height: height,
      prompt: prompt,
      numImages: 1,
      promptStyle: style.rawValue,
      inputImage: nil,
      checkCost: false
    )

    let response: InferenceResponse = try await performRequest(
      endpoint: "/inferences",
      request: request
    )

    guard let firstImage = response.base64Images.first,
      let imageData = Data(base64Encoded: firstImage),
      let resultImage = UIImage(data: imageData)
    else {
      throw NetworkingError.imageDecodingFailed
    }

    return resultImage
  }

  func checkCredits() async throws -> Int {
    let url = URL(string: "\(baseURL)/inferences/credits")!
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue(apiKey, forHTTPHeaderField: "X-RD-Token")

    let (data, response) = try await URLSession.shared.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse,
      httpResponse.statusCode == 200
    else {
      throw NetworkingError.invalidResponse
    }

    let creditsResponse = try JSONDecoder().decode(CreditsResponse.self, from: data)
    return creditsResponse.credits
  }

  func checkPixelateCost(_ image: UIImage) async throws -> Double {
    // Resize image to fit within API limits (max 256x256)
        let resizedImage = await ImageUtils().resizeImage(image, maxDimension: 256)

        // Convert UIImage to base64 RGB (no transparency)
        guard let base64Image = await ImageUtils().imageToBase64RGB(resizedImage) else {
            throw NetworkingError.imageConversionFailed
        }

    let request = InferenceRequest(
      width: Int(resizedImage.size.width),
      height: Int(resizedImage.size.height),
      prompt: "",
      numImages: 1,
      promptStyle: "rd_pro__pixelate",
      inputImage: base64Image,
      checkCost: true
    )

    let response: InferenceResponse = try await performRequest(
      endpoint: "/inferences",
      request: request
    )

    return response.balanceCost ?? Double(response.creditCost)
  }

  func checkGenerateCost(
    prompt: String,
    style: RetroDiffusionModel,
    width: Int,
    height: Int
  ) async throws -> Double {
    let request = InferenceRequest(
      width: width,
      height: height,
      prompt: prompt,
      numImages: 1,
      promptStyle: style.rawValue,
      inputImage: nil,
      checkCost: true
    )

    let response: InferenceResponse = try await performRequest(
      endpoint: "/inferences",
      request: request
    )

    return response.balanceCost ?? Double(response.creditCost)
  }

  private func performRequest<T: Codable, U: Codable>(
    endpoint: String,
    request: T
  ) async throws -> U {
    let url = URL(string: "\(baseURL)\(endpoint)")!
    print("🌐 [Network] Request URL: \(url.absoluteString)")

    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = "POST"
    urlRequest.setValue(apiKey, forHTTPHeaderField: "X-RD-Token")
    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let encoder = JSONEncoder()
    let requestBody = try encoder.encode(request)
    urlRequest.httpBody = requestBody

    print("🌐 [Network] Request body size: \(requestBody.count) bytes")
    if let requestDict = try? JSONSerialization.jsonObject(with: requestBody) as? [String: Any] {
      // Log request without the large base64 image
      var logDict = requestDict
      if let inputImage = logDict["input_image"] as? String {
        logDict["input_image"] = "[\(inputImage.count) chars]"
      }
      print("🌐 [Network] Request payload: \(logDict)")
    }

    print("🌐 [Network] Sending request...")
    let (data, response) = try await URLSession.shared.data(for: urlRequest)

    print("🌐 [Network] Response received")
    print("🌐 [Network] Response data size: \(data.count) bytes")

    guard let httpResponse = response as? HTTPURLResponse else {
      print("❌ [Network] Invalid HTTP response")
      throw NetworkingError.invalidResponse
    }

    print("🌐 [Network] Status code: \(httpResponse.statusCode)")
    print("🌐 [Network] Response headers: \(httpResponse.allHeaderFields)")

    if httpResponse.statusCode != 200 {
      print("❌ [Network] Non-200 status code: \(httpResponse.statusCode)")

      // Try to decode error message
      if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
        print("❌ [Network] Error response: \(errorData)")
        if let errorMessage = errorData["error"] as? String {
          throw NetworkingError.apiError(errorMessage)
        }
      } else if let errorString = String(data: data, encoding: .utf8) {
        print("❌ [Network] Error response (raw): \(errorString)")
      }

      // Provide helpful error messages for common status codes
      if httpResponse.statusCode == 413 {
        throw NetworkingError.apiError("Image is too large. Please try a smaller image.")
      }

      throw NetworkingError.httpError(httpResponse.statusCode)
    }

    // Log response before decoding
    if let responseString = String(data: data, encoding: .utf8) {
      // Truncate if too long (base64 images can be huge)
      if responseString.count > 500 {
        print("🌐 [Network] Response preview: \(String(responseString.prefix(500)))...")
      } else {
        print("🌐 [Network] Response: \(responseString)")
      }
    }

    print("🌐 [Network] Attempting to decode response...")
    let decoder = JSONDecoder()

    do {
      let decoded = try decoder.decode(U.self, from: data)
      print("✅ [Network] Successfully decoded response")
      return decoded
    } catch {
      print("❌ [Network] Decoding failed: \(error)")
      print("❌ [Network] Decoding error details: \(error.localizedDescription)")
      if let decodingError = error as? DecodingError {
        switch decodingError {
        case .dataCorrupted(let context):
          print("❌ [Network] Data corrupted: \(context.debugDescription)")
          print("❌ [Network] Coding path: \(context.codingPath)")
        case .keyNotFound(let key, let context):
          print("❌ [Network] Key not found: \(key.stringValue)")
          print("❌ [Network] Coding path: \(context.codingPath)")
        case .typeMismatch(let type, let context):
          print("❌ [Network] Type mismatch: \(type)")
          print("❌ [Network] Coding path: \(context.codingPath)")
        case .valueNotFound(let type, let context):
          print("❌ [Network] Value not found: \(type)")
          print("❌ [Network] Coding path: \(context.codingPath)")
        @unknown default:
          print("❌ [Network] Unknown decoding error")
        }
      }
      throw error
    }
  }

}

enum NetworkingError: LocalizedError {
  case imageConversionFailed
  case imageDecodingFailed
  case invalidResponse
  case httpError(Int)
  case apiError(String)

  var errorDescription: String? {
    switch self {
    case .imageConversionFailed:
      return "Failed to convert image to base64"
    case .imageDecodingFailed:
      return "Failed to decode image from response"
    case .invalidResponse:
      return "Invalid response from server"
    case .httpError(let code):
      return "HTTP error: \(code)"
    case .apiError(let message):
      return "API error: \(message)"
    }
  }
}
