//
//  MainTabView.swift
//  RetroDiffusionApp
//
//  Created by Thomas Ricouard on 29/11/25.
//

import SwiftUI

struct MainTabView: View {
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

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}

#Preview {
    MainTabView()
        .environment(Networking())
}
