import Foundation
import UIKit

extension APIClient {
    func startGoogleOAuth() async {
        await startOAuth(path: "/v1/oauth/google/start")
    }

    func startNotionOAuth() async {
        await startOAuth(path: "/v1/oauth/notion/start")
    }

    private func startOAuth(path: String) async {
        do {
            let request = try authorizedRequest(path: path, method: "GET")
            let (data, _) = try await session.data(for: request)
            if let payload = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let urlString = payload["authorization_url"] as? String,
               let url = URL(string: urlString) {
                await MainActor.run {
                    UIApplication.shared.open(url)
                }
            }
        } catch {
            print("OAuth start failed: \(error)")
        }
    }
}
