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
        }
    }
}

#Preview {
    MainTabView()
        .environment(Networking())
}
