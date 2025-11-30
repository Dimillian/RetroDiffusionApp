//
//  SettingsView.swift
//  RetroDiffusionApp
//
//  Created by Thomas Ricouard on 29/11/25.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage(Constants.UserDefaultsKeys.customAPIKey) private var customAPIKey: String = ""
    @Environment(Networking.self) private var networking

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    SecureField("API Key", text: $customAPIKey)
                        .textContentType(.password)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)

                    if !customAPIKey.isEmpty {
                        Button("Clear API Key") {
                            customAPIKey = ""
                        }
                        .foregroundColor(.red)
                    }
                } header: {
                    Text("API Configuration")
                } footer: {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Enter your RetroDiffusion API key. If set, this will override the key from Config.plist.")

                        Link("Get your API key", destination: URL(string: Constants.URLs.retrodiffusionWebsite)!)
                            .font(.footnote)
                    }
                    .padding(.top, 4)
                }

                Section {
                    Link(destination: URL(string: Constants.URLs.githubRepository)!) {
                        HStack {
                            Label("Source Code", systemImage: "link")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .onChange(of: customAPIKey) { oldValue, newValue in
                networking.updateAPIKey(newValue.isEmpty ? nil : newValue)
            }
        }
    }
}

#Preview {
    SettingsView()
        .environment(Networking())
}
