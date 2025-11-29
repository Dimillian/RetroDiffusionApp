//
//  RetroDiffusionAppApp.swift
//  RetroDiffusionApp
//
//  Created by Thomas Ricouard on 29/11/25.
//

import SwiftUI

@main
struct RetroDiffusionAppApp: App {
    @State private var networking = Networking()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(networking)
        }
    }
}
