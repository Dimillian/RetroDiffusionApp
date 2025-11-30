//
//  QueueAccessoryView.swift
//  RetroDiffusionApp
//
//  Created by Thomas Ricouard on 29/11/25.
//

import SwiftUI

struct QueueAccessoryView: View {
    @Environment(GenerationQueue.self) private var generationQueue

    var hasTasks: Bool {
        !generationQueue.pendingTasks.isEmpty || !generationQueue.inProgressTasks.isEmpty
    }

    var totalTasks: Int {
        generationQueue.pendingTasks.count + generationQueue.inProgressTasks.count
    }

    var inProgressCount: Int {
        generationQueue.inProgressTasks.count
    }

    var pendingCount: Int {
        generationQueue.pendingTasks.count
    }

    var body: some View {
        if hasTasks {
            HStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)

                VStack(alignment: .leading, spacing: 2) {
                    if inProgressCount > 0 {
                        Text("Processing \(inProgressCount) task\(inProgressCount == 1 ? "" : "s")")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    } else {
                        Text("\(pendingCount) task\(pendingCount == 1 ? "" : "s") queued")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }

                    if inProgressCount > 0 && pendingCount > 0 {
                        Text("\(pendingCount) in queue")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                if inProgressCount > 0 {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        } else {
            Text("No tasks processing")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
        }
    }
}

#Preview {
    QueueAccessoryView()
        .environment(GenerationQueue())
}
