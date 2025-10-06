import Foundation

actor APIClient {
    let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private var accessToken: String? {
        get { KeychainStorage.shared.accessToken }
        set { KeychainStorage.shared.accessToken = newValue }
    }

    init(session: URLSession = .shared) {
        self.session = session
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder
    }

    func configureToken(_ token: String) {
        accessToken = token
    }

    func fetchChats() async throws -> [ChatSummary] {
        let request = try authorizedRequest(path: "/v1/chats", method: "GET")
        let (data, _) = try await session.data(for: request)
        let response = try decoder.decode(ChatListResponse.self, from: data)
        return response.chats
    }

    func fetchChatDetail(id: Int) async throws -> Conversation {
        let request = try authorizedRequest(path: "/v1/chats/\(id)", method: "GET")
        let (data, _) = try await session.data(for: request)
        return try decoder.decode(Conversation.self, from: data)
    }

    func createChat(title: String) async throws -> ChatSummaryResponse {
        var request = try authorizedRequest(path: "/v1/chats", method: "POST")
        request.httpBody = try encoder.encode(ChatCreateRequest(title: title))
        let (data, _) = try await session.data(for: request)
        return try decoder.decode(ChatSummaryResponse.self, from: data)
    }

    func sendMessageStream(
        chatID: Int,
        request: MessageCreateRequest,
        sseClient: SSEClient,
        onEvent: @escaping (SSEEvent) -> Void
    ) async throws {
        var urlRequest = try authorizedRequest(path: "/v1/chats/\(chatID)/messages", method: "POST")
        urlRequest.addValue("text/event-stream", forHTTPHeaderField: "Accept")
        urlRequest.httpBody = try encoder.encode(request)
        try await sseClient.stream(request: urlRequest, onEvent: onEvent)
    }

    func authorizedRequest(path: String, method: String) throws -> URLRequest {
        let url = AppConfiguration.baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = accessToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
}

private struct ChatListResponse: Codable {
    let chats: [ChatSummary]
}

struct ChatSummaryResponse: Codable {
    let id: Int
    let title: String
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case updatedAt = "updated_at"
    }
}

struct ChatCreateRequest: Codable {
    let title: String
}

struct MessageCreateRequest: Codable {
    let message: String
    let model: String
    let temperature: Double
    let toolsEnabled: Bool

    enum CodingKeys: String, CodingKey {
        case message
        case model
        case temperature
        case toolsEnabled = "tools_enabled"
    }
}
