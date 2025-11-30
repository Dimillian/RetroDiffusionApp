//
//  LibraryStore.swift
//  RetroDiffusionApp
//
//  Created by Thomas Ricouard on 29/11/25.
//

import Foundation
import SQLite3

nonisolated struct LibraryImage: Identifiable, Codable, Sendable {
    let id: UUID
    let fileName: String
    let createdAt: Date
    let prompt: String?
    let model: String?
    let width: Int?
    let height: Int?

    init(
        id: UUID = UUID(),
        fileName: String,
        createdAt: Date = Date(),
        prompt: String? = nil,
        model: String? = nil,
        width: Int? = nil,
        height: Int? = nil
    ) {
        self.id = id
        self.fileName = fileName
        self.createdAt = createdAt
        self.prompt = prompt
        self.model = model
        self.width = width
        self.height = height
    }
}

enum LibraryStoreError: LocalizedError {
    case databaseUnavailable
    case failedToWriteImage
    case failedToSaveMetadata

    var errorDescription: String? {
        switch self {
        case .databaseUnavailable:
            return "Unable to access the library database."
        case .failedToWriteImage:
            return "Failed to save the image to disk."
        case .failedToSaveMetadata:
            return "Failed to save image metadata."
        }
    }
}

actor LibraryStore {
    private let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
  
    private var db: OpaquePointer?
    private let libraryDirectory: URL

    init?() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        libraryDirectory = documentsPath.appendingPathComponent("Library", isDirectory: true)

        do {
            try FileManager.default.createDirectory(at: libraryDirectory, withIntermediateDirectories: true)
        } catch {
            return nil
        }

        let dbURL = libraryDirectory.appendingPathComponent("library.sqlite")
        guard sqlite3_open(dbURL.path, &db) == SQLITE_OK else {
            sqlite3_close(db)
            db = nil
            return nil
        }

        let createTableSQL = """
        CREATE TABLE IF NOT EXISTS library_images (
            id TEXT PRIMARY KEY,
            file_name TEXT NOT NULL,
            created_at REAL NOT NULL,
            prompt TEXT,
            model TEXT,
            width INTEGER,
            height INTEGER
        );
        """

        guard sqlite3_exec(db, createTableSQL, nil, nil, nil) == SQLITE_OK else {
            sqlite3_close(db)
            db = nil
            return nil
        }
    }

    func save(
        imageData: Data,
        prompt: String?,
        model: String?,
        width: Int?,
        height: Int?
    ) throws -> LibraryImage {
        guard let db = db else {
            throw LibraryStoreError.databaseUnavailable
        }

        let id = UUID()
        let fileName = "\(id.uuidString).png"
        let fileURL = libraryDirectory.appendingPathComponent(fileName)

        do {
            try imageData.write(to: fileURL)
        } catch {
            throw LibraryStoreError.failedToWriteImage
        }

        let createdAt = Date()
        let insertSQL = """
        INSERT INTO library_images (id, file_name, created_at, prompt, model, width, height)
        VALUES (?, ?, ?, ?, ?, ?, ?);
        """

        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, insertSQL, -1, &statement, nil) == SQLITE_OK else {
            throw LibraryStoreError.failedToSaveMetadata
        }

        defer { sqlite3_finalize(statement) }

        sqlite3_bind_text(statement, 1, id.uuidString, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(statement, 2, fileName, -1, SQLITE_TRANSIENT)
        sqlite3_bind_double(statement, 3, createdAt.timeIntervalSince1970)

        if let prompt {
            sqlite3_bind_text(statement, 4, prompt, -1, SQLITE_TRANSIENT)
        } else {
            sqlite3_bind_null(statement, 4)
        }

        if let model {
            sqlite3_bind_text(statement, 5, model, -1, SQLITE_TRANSIENT)
        } else {
            sqlite3_bind_null(statement, 5)
        }

        if let width {
            sqlite3_bind_int(statement, 6, Int32(width))
        } else {
            sqlite3_bind_null(statement, 6)
        }

        if let height {
            sqlite3_bind_int(statement, 7, Int32(height))
        } else {
            sqlite3_bind_null(statement, 7)
        }

        guard sqlite3_step(statement) == SQLITE_DONE else {
            throw LibraryStoreError.failedToSaveMetadata
        }

        return LibraryImage(
            id: id,
            fileName: fileName,
            createdAt: createdAt,
            prompt: prompt,
            model: model,
            width: width,
            height: height
        )
    }

    func fetchPage(offset: Int, limit: Int) -> [LibraryImage] {
        guard let db = db else { return [] }

        let querySQL = """
        SELECT id, file_name, created_at, prompt, model, width, height
        FROM library_images
        ORDER BY created_at DESC
        LIMIT ? OFFSET ?;
        """

        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, querySQL, -1, &statement, nil) == SQLITE_OK else {
            return []
        }
        defer { sqlite3_finalize(statement) }

        sqlite3_bind_int(statement, 1, Int32(limit))
        sqlite3_bind_int(statement, 2, Int32(offset))

        var results: [LibraryImage] = []

        while sqlite3_step(statement) == SQLITE_ROW {
            guard
                let idCString = sqlite3_column_text(statement, 0),
                let fileNameCString = sqlite3_column_text(statement, 1)
            else { continue }

            let idString = String(cString: idCString)
            let fileName = String(cString: fileNameCString)
            guard let id = UUID(uuidString: idString) else { continue }

            let createdAt = Date(timeIntervalSince1970: sqlite3_column_double(statement, 2))

            let prompt = sqlite3_column_text(statement, 3).flatMap { String(cString: $0) }
            let model = sqlite3_column_text(statement, 4).flatMap { String(cString: $0) }
            let width = sqlite3_column_type(statement, 5) != SQLITE_NULL ? Int(sqlite3_column_int(statement, 5)) : nil
            let height = sqlite3_column_type(statement, 6) != SQLITE_NULL ? Int(sqlite3_column_int(statement, 6)) : nil

            let image = LibraryImage(
                id: id,
                fileName: fileName,
                createdAt: createdAt,
                prompt: prompt,
                model: model,
                width: width,
                height: height
            )
            results.append(image)
        }

        return results
    }

    func delete(id: UUID) {
        guard let db = db else { return }

        // Retrieve file name to remove the file as well
        let fileNameQuery = "SELECT file_name FROM library_images WHERE id = ?;"
        var nameStatement: OpaquePointer?
        var fileName: String?

        if sqlite3_prepare_v2(db, fileNameQuery, -1, &nameStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(nameStatement, 1, id.uuidString, -1, SQLITE_TRANSIENT)
            if sqlite3_step(nameStatement) == SQLITE_ROW, let cString = sqlite3_column_text(nameStatement, 0) {
                fileName = String(cString: cString)
            }
        }
        sqlite3_finalize(nameStatement)

        if let fileName {
            let fileURL = libraryDirectory.appendingPathComponent(fileName)
            try? FileManager.default.removeItem(at: fileURL)
        }

        let deleteSQL = "DELETE FROM library_images WHERE id = ?;"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, deleteSQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, id.uuidString, -1, SQLITE_TRANSIENT)
            sqlite3_step(statement)
        }
        sqlite3_finalize(statement)
    }

    func imageData(forFileName fileName: String) -> Data? {
        let fileURL = libraryDirectory.appendingPathComponent(fileName)
        return try? Data(contentsOf: fileURL)
    }
}
