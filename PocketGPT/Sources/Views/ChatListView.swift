import SwiftUI

struct ChatListView: View {
    @EnvironmentObject private var appState: AppState
    @State private var showingNewChat = false

    var body: some View {
        List(selection: $appState.selectedChatID) {
            ForEach(appState.chats) { chat in
                VStack(alignment: .leading) {
                    Text(chat.title)
                        .font(.headline)
                    Text(chat.updatedAt, style: .relative)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingNewChat = true
                } label: {
                    Image(systemName: "square.and.pencil")
                }
            }
        }
        .sheet(isPresented: $showingNewChat) {
            NavigationStack {
                Form {
                    TextField("Title", text: $title)
                }
                .navigationTitle("New Chat")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showingNewChat = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Create") { Task { await createChat() } }
                            .disabled(title.isEmpty)
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }

    @State private var title: String = ""

    private func createChat() async {
        guard !title.isEmpty else { return }
        _ = await appState.createChat(title: title)
        title = ""
        showingNewChat = false
    }
}
