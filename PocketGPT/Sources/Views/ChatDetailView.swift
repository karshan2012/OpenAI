import SwiftUI

struct ChatDetailView: View {
    let chatID: Int
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = ChatDetailViewModel()

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 16) {
                        ForEach(viewModel.messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                        if viewModel.isStreaming {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.messages) { _, messages in
                    if let last = messages.last {
                        withAnimation {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }

            MessageComposer(text: $viewModel.currentInput, onSend: {
                Task { await viewModel.send(chatID: chatID, appState: appState) }
            })
            .padding()
        }
        .task {
            await viewModel.load(chatID: chatID, appState: appState)
        }
        .navigationTitle(viewModel.chatTitle)
        .toolbar {
            NavigationLink("Settings") {
                SettingsView()
            }
        }
    }
}
