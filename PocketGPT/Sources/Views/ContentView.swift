import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationSplitView {
            ChatListView()
                .navigationTitle("PocketGPT")
        } detail: {
            if let chatID = appState.selectedChatID {
                ChatDetailView(chatID: chatID)
            } else {
                Text("Select or create a chat")
                    .foregroundStyle(.secondary)
            }
        }
    }
}
