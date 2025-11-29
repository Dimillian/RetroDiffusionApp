//
//  CostPreviewView.swift
//  RetroDiffusionApp
//
//  Created by Thomas Ricouard on 29/11/25.
//

import SwiftUI

struct CostPreviewView: View {
    let cost: Double?
    let checkingCost: Bool

    var body: some View {
        if let cost = cost {
            HStack {
                Image(systemName: "creditcard")
                    .foregroundColor(.secondary)
                Text("Cost: \(cost, specifier: "%.2f") credits")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(Color.secondary.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal)
        } else if checkingCost {
            HStack {
                ProgressView()
                    .scaleEffect(0.8)
                Text("Checking cost...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(Color.secondary.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        CostPreviewView(cost: 0.25, checkingCost: false)
        CostPreviewView(cost: nil, checkingCost: true)
        CostPreviewView(cost: nil, checkingCost: false)
    }
    .padding()
}
