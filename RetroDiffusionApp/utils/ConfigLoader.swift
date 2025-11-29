//
//  ConfigLoader.swift
//  RetroDiffusionApp
//
//  Created by Thomas Ricouard on 29/11/25.
//

import Foundation

enum ConfigLoader {
    static func loadAPIKey() -> String? {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let apiKey = plist["API_KEY"] as? String else {
            return nil
        }
        return apiKey
    }
}
