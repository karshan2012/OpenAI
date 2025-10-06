import Foundation

struct ChatSummary: Identifiable, Codable, Hashable {
    var id: Int
    var title: String
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case updatedAt = "updated_at"
    }
}

struct ChatMessage: Identifiable, Codable, Hashable {
    enum Role: String, Codable {
        case user
        case assistant
        case tool
    }

    var id: Int
    var role: Role
    var content: String
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case role
        case content
        case createdAt = "created_at"
    }
}

struct Conversation: Identifiable, Codable {
    var id: Int
    var title: String
    var messages: [ChatMessage]
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case messages
        case updatedAt = "updated_at"
    }
}

struct ProviderStatus: Codable {
    var googleConnected: Bool = false
    var notionConnected: Bool = false
}

struct UserSettings: Codable {
    var selectedModel: String = "gpt-4o-mini"
    var temperature: Double = 0.6
    var maxTokens: Int = 8000
    var enableSafety: Bool = true
}
