import Foundation
import Combine

final class AppState: ObservableObject {
    @Published var chats: [ChatSummary] = []
    @Published var selectedChatID: Int?
    @Published var settings = UserSettings()
    @Published var providerStatus = ProviderStatus()

    let storage: ConversationStore
    let apiClient: APIClient
    let sseClient: SSEClient

    private var cancellables: Set<AnyCancellable> = []

    init(storage: ConversationStore = ConversationStore(),
         apiClient: APIClient = APIClient(),
         sseClient: SSEClient = SSEClient()) {
        self.storage = storage
        self.apiClient = apiClient
        self.sseClient = sseClient

        Task {
            await refreshChats()
        }
    }

    @MainActor
    func refreshChats() async {
        do {
            let remote = try await apiClient.fetchChats()
            chats = remote
            try remote.forEach { try storage.saveChat($0) }
            if selectedChatID == nil {
                selectedChatID = remote.first?.id
            }
        } catch {
            do {
                let cached = try storage.fetchChats()
                chats = cached
                if selectedChatID == nil {
                    selectedChatID = cached.first?.id
                }
            } catch {
                print("Failed to load chats: \(error)")
            }
        }
    }

    @MainActor
    func createChat(title: String) async -> ChatSummary? {
        do {
            let chat = try await apiClient.createChat(title: title)
            let summary = ChatSummary(id: chat.id, title: chat.title, updatedAt: chat.updatedAt)
            chats.insert(summary, at: 0)
            try storage.saveChat(summary)
            selectedChatID = summary.id
            return summary
        } catch {
            print("Failed to create chat: \(error)")
            return nil
        }
    }
}
