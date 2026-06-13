import Foundation
import UIKit

enum CrashTrail {
    private static let sqlLoggingEnabled = false

    static func log(_ message: String, screenName: String? = nil) {

        print("🧨 CrashTrail: \(message)")

        UserDefaults.standard.set(message, forKey: "LastCrashTrail")
        UserDefaults.standard.set(Date(), forKey: "LastCrashTrailDate")

        guard sqlLoggingEnabled else { return }
        Task {
            await sendToSql(message, screenName: screenName)
        }
    }

    static var lastMessage: String {
        UserDefaults.standard.string(forKey: "LastCrashTrail") ?? "None"
    }

    private static func sendToSql(_ message: String, screenName: String?) async {
        guard let url = URL(string: "\(ApiConfig.baseUrl)/api/eldertools/breadcrumb") else {
            return
        }

        let payload: [String: Any?] = [
            "clientId": nil,
            "memberId": nil,
            "appName": "ServiceLink",
            "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
            "screenName": screenName,
            "message": message,
            "deviceInfo": UIDevice.current.model
        ]

        do {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONSerialization.data(
                withJSONObject: payload.compactMapValues { $0 }
            )

            _ = try await URLSession.shared.data(for: request)
        } catch {
            print("🧨 CrashTrail SQL failed:", error)
        }
    }
}
