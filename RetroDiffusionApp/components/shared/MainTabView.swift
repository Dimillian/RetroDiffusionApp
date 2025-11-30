//
//  MainTabView.swift
//  RetroDiffusionApp
//
//  Created by Thomas Ricouard on 29/11/25.
//

import SwiftUI

struct MainTabView: View {
    @Environment(GenerationQueue.self) private var generationQueue

    var body: some View {
        TabView {
            PixelateView()
                .tabItem {
                    Label("Pixelate", systemImage: "photo.artframe")
                }

            GenerateView()
                .tabItem {
                    Label("Generate", systemImage: "sparkles")
                }

            LibraryView()
                .tabItem {
                    Label("Library", systemImage: "photo.on.rectangle")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
        .tabViewBottomAccessory {
            QueueAccessoryView()
        }
    }
}

#Preview {
    MainTabView()
        .environment(Networking())
        .environment(LibraryManager())
        .environment(GenerationQueue())
}
