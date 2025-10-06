import Foundation
import SwiftUI

@MainActor
final class ChatDetailViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var currentInput: String = ""
    @Published var chatTitle: String = "Chat"
    @Published var isStreaming: Bool = false

    func load(chatID: Int, appState: AppState) async {
        do {
            let conversation = try await appState.apiClient.fetchChatDetail(id: chatID)
            chatTitle = conversation.title
            messages = conversation.messages
        } catch {
            print("Failed to load conversation: \(error)")
        }
    }

    func send(chatID: Int, appState: AppState) async {
        guard !currentInput.isEmpty else { return }
        let tempId = (messages.last?.id ?? 0) + 1
        let userMessage = ChatMessage(id: tempId, role: .user, content: currentInput, createdAt: Date())
        messages.append(userMessage)
        let text = currentInput
        currentInput = ""
        isStreaming = true
        do {
            try await appState.apiClient.sendMessageStream(
                chatID: chatID,
                request: MessageCreateRequest(
                    message: text,
                    model: appState.settings.selectedModel,
                    temperature: appState.settings.temperature,
                    toolsEnabled: true
                ),
                sseClient: appState.sseClient,
                onEvent: { [weak self] event in
                    Task { @MainActor in
                        self?.handle(event: event)
                    }
                }
            )
        } catch {
            print("Failed to stream: \(error)")
        }
        isStreaming = false
    }

    private func handle(event: SSEEvent) {
        switch event.event {
        case "token":
            guard let payload = try? JSONDecoder().decode(TokenEvent.self, from: event.data) else { return }
            if let lastIndex = messages.lastIndex(where: { $0.role == .assistant }) {
                messages[lastIndex].content.append(payload.delta)
            } else {
                let message = ChatMessage(id: (messages.last?.id ?? 0) + 1, role: .assistant, content: payload.delta, createdAt: Date())
                messages.append(message)
            }
        case "tool_call":
            guard let payload = try? JSONDecoder().decode(ToolCallEvent.self, from: event.data) else { return }
            let message = ChatMessage(id: (messages.last?.id ?? 0) + 1, role: .tool, content: "Calling \(payload.name)...", createdAt: Date())
            messages.append(message)
        case "tool_result":
            guard let payload = try? JSONDecoder().decode(ToolResultEvent.self, from: event.data) else { return }
            if let index = messages.lastIndex(where: { $0.role == .tool }) {
                messages[index].content = "Tool \(payload.name) succeeded: \(payload.result.description)"
            }
        case "done":
            isStreaming = false
        default:
            break
        }
    }
}

private struct TokenEvent: Decodable {
    let delta: String
}

private struct ToolCallEvent: Decodable {
    let name: String
    let arguments: [String: String]
}

private struct ToolResultEvent: Decodable {
    let name: String
    let result: [String: String]
}
