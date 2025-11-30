//
//  GenerationQueue.swift
//  RetroDiffusionApp
//
//  Created by Thomas Ricouard on 29/11/25.
//

import Foundation
import UIKit

@MainActor
@Observable
class GenerationQueue {
    private var tasks: [GenerationTask] = []

    var pendingTasks: [GenerationTask] {
        tasks.filter { $0.isPending }
    }

    var inProgressTasks: [GenerationTask] {
        tasks.filter { $0.isInProgress }
    }

    var completedTasks: [GenerationTask] {
        tasks.filter { $0.isCompleted }
    }

    var failedTasks: [GenerationTask] {
        tasks.filter { $0.isFailed }
    }

    private var networkClient: NetworkClient?
    private var libraryClient: LibraryClient?

    func setDependencies(networkClient: NetworkClient, libraryClient: LibraryClient) {
        self.networkClient = networkClient
        self.libraryClient = libraryClient
    }

  
    @discardableResult
    func enqueueGenerate(
        prompt: String,
        model: RetroDiffusionModel,
        width: Int,
        height: Int
    ) -> UUID {
        let task = GenerationTask(
            type: .generate,
            state: .pending,
            prompt: prompt,
            model: model,
            width: width,
            height: height
        )

        tasks.append(task)
        startTask(task)
        return task.id
    }

    @discardableResult
    func enqueuePixelate(image: UIImage) -> UUID {
        let task = GenerationTask(
            type: .pixelate,
            state: .pending,
            sourceImage: image
        )

        tasks.append(task)
        startTask(task)
        return task.id
    }

    private func startTask(_ task: GenerationTask) {
        guard let networkClient = networkClient else {
            return
        }

        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else {
            return
        }

        var updatedTask = tasks[index]
        updatedTask.state = .inProgress
        tasks[index] = updatedTask

        Task { @MainActor in
            do {
                let resultImage: UIImage

                switch task.type {
                case .generate:
                    guard let prompt = task.prompt,
                          let model = task.model,
                          let width = task.width,
                          let height = task.height else {
                        throw GenerationQueueError.invalidTaskData
                    }
                    resultImage = try await networkClient.generateImage(
                        prompt: prompt,
                        style: model,
                        width: width,
                        height: height
                    )

                case .pixelate:
                    guard let sourceImage = task.sourceImage else {
                        throw GenerationQueueError.invalidTaskData
                    }
                    resultImage = try await networkClient.pixelateImage(sourceImage)
                }

                await markCompleted(id: task.id, image: resultImage)
            } catch {
                await markFailed(id: task.id, error: error)
            }
        }
    }

    func markCompleted(id: UUID, image: UIImage) async {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else {
            return
        }

        var task = tasks[index]
        task.state = .completed(image)
        tasks[index] = task

        if let libraryClient = libraryClient {
            switch task.type {
            case .generate:
                await libraryClient.save(
                    image: image,
                    prompt: task.prompt,
                    model: task.model?.rawValue,
                    width: task.width,
                    height: task.height
                )
            case .pixelate:
                await libraryClient.save(image: image)
            }
        }
    }

    func markFailed(id: UUID, error: Error) async {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else {
            return
        }

        var task = tasks[index]
        let errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        task.state = .failed(errorMessage)
        tasks[index] = task
    }

    func cancelTask(id: UUID) {
        tasks.removeAll { $0.id == id && $0.isPending }
    }

    func task(withId id: UUID) -> GenerationTask? {
        tasks.first(where: { $0.id == id })
    }
}

enum GenerationQueueError: LocalizedError {
    case invalidTaskData

    var errorDescription: String? {
        switch self {
        case .invalidTaskData:
            return "Task data is invalid or missing"
        }
    }
}
