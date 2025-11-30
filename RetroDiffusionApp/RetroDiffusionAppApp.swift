//
//  RetroDiffusionAppApp.swift
//  RetroDiffusionApp
//
//  Created by Thomas Ricouard on 29/11/25.
//

import SwiftUI

@main
struct RetroDiffusionAppApp: App {
    @State private var networking = NetworkClient()
    @State private var libraryClient = LibraryClient()
    @State private var generationQueue = GenerationQueue()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(networking)
                .environment(libraryClient)
                .environment(generationQueue)
                .onAppear {
                    generationQueue.setDependencies(networkClient: networking, libraryClient: libraryClient)
                }
        }
    }
}
