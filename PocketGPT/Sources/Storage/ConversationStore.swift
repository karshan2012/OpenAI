import Foundation
import SQLite3

final class ConversationStore {
    private var db: OpaquePointer?
    private let queue = DispatchQueue(label: "ConversationStore")

    init() {
        openDatabase()
        createTablesIfNeeded()
    }

    deinit {
        sqlite3_close(db)
    }

    func fetchChats() throws -> [ChatSummary] {
        var results: [ChatSummary] = []
        try queue.sync {
            let query = "SELECT id, title, updated_at FROM chats ORDER BY updated_at DESC"
            var statement: OpaquePointer?
            guard sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK else {
                throw StorageError.queryFailed
            }
            defer { sqlite3_finalize(statement) }
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = sqlite3_column_int64(statement, 0)
                if let titleCString = sqlite3_column_text(statement, 1) {
                    let title = String(cString: titleCString)
                    let timestamp = sqlite3_column_double(statement, 2)
                    results.append(ChatSummary(id: Int(id), title: title, updatedAt: Date(timeIntervalSince1970: timestamp)))
                }
            }
        }
        return results
    }

    func saveChat(_ chat: ChatSummary) throws {
        try queue.sync {
            let insert = "INSERT OR REPLACE INTO chats (id, title, updated_at) VALUES (?, ?, ?)"
            var statement: OpaquePointer?
            guard sqlite3_prepare_v2(db, insert, -1, &statement, nil) == SQLITE_OK else {
                throw StorageError.queryFailed
            }
            defer { sqlite3_finalize(statement) }
            sqlite3_bind_int64(statement, 1, sqlite3_int64(chat.id))
            sqlite3_bind_text(statement, 2, chat.title, -1, SQLITE_TRANSIENT)
            sqlite3_bind_double(statement, 3, chat.updatedAt.timeIntervalSince1970)
            guard sqlite3_step(statement) == SQLITE_DONE else {
                throw StorageError.queryFailed
            }
        }
    }

    private func openDatabase() {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("pocketgpt.sqlite")
        if sqlite3_open(url.path, &db) != SQLITE_OK {
            print("Failed to open SQLite database")
        }
    }

    private func createTablesIfNeeded() {
        let createSQL = """
        CREATE TABLE IF NOT EXISTS chats (
            id INTEGER PRIMARY KEY,
            title TEXT NOT NULL,
            updated_at REAL NOT NULL
        );
        """
        if sqlite3_exec(db, createSQL, nil, nil, nil) != SQLITE_OK {
            print("Failed to create tables")
        }
    }

    enum StorageError: Error {
        case queryFailed
    }
}
