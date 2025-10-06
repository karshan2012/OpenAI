import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        Form {
            Section("Model") {
                TextField("Model", text: $appState.settings.selectedModel)
                Slider(value: $appState.settings.temperature, in: 0...1, step: 0.05) {
                    Text("Temperature")
                }
                Stepper(value: $appState.settings.maxTokens, in: 1000...32000, step: 500) {
                    Text("Max tokens: \(appState.settings.maxTokens)")
                }
                Toggle("Safety filters", isOn: $appState.settings.enableSafety)
            }
            Section("Connections") {
                Toggle("Google Calendar", isOn: Binding(
                    get: { appState.providerStatus.googleConnected },
                    set: { newValue in
                        Task { await toggleGoogle(newValue) }
                    }
                ))
                Toggle("Notion", isOn: Binding(
                    get: { appState.providerStatus.notionConnected },
                    set: { newValue in
                        Task { await toggleNotion(newValue) }
                    }
                ))
            }
        }
        .navigationTitle("Settings")
    }

    private func toggleGoogle(_ enabled: Bool) async {
        if enabled {
            await appState.apiClient.startGoogleOAuth()
        }
    }

    private func toggleNotion(_ enabled: Bool) async {
        if enabled {
            await appState.apiClient.startNotionOAuth()
        }
    }
}
