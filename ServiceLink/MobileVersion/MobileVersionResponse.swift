//
//  MobileVersionResponse.swift
//  ServiceLink
//
//  Created by Michael Anderson on 5/24/26.
//

import Foundation

struct MobileVersionResponse: Codable {
    let latestVersion: String
    let minimumSupportedVersion: String
    let appStoreUrl: String
    let updateMessage: String
}

enum MobileVersionCheckResult {
    case current
    case updateAvailable(MobileVersionResponse)
    case updateRequired(MobileVersionResponse)
}

final class MobileVersionService {

    static let shared = MobileVersionService()

    private init() {}

    func checkIosVersion() async -> MobileVersionCheckResult {
        guard let url = URL(
            string: "https://wsp-tools-dphadgczhbcnazab.centralus-01.azurewebsites.net/api/MobileVersion/servicelink/ios"
        ) else {
            return .current
        }

        do {
            let (data, response) = try await ApiClient.shared.data(from: url)

            guard let http = response as? HTTPURLResponse,
                  http.statusCode == 200 else {
                return .current
            }

            let versionInfo = try JSONDecoder().decode(
                MobileVersionResponse.self,
                from: data
            )

            let currentVersion =
                Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
                ?? "0.0.0"

            if isVersion(currentVersion, lessThan: versionInfo.minimumSupportedVersion) {
                return .updateRequired(versionInfo)
            }

            if isVersion(currentVersion, lessThan: versionInfo.latestVersion) {
                return .updateAvailable(versionInfo)
            }

            return .current

        } catch {
            print("Version check failed: \(error)")
            return .current
        }
    }

    private func isVersion(_ current: String, lessThan target: String) -> Bool {
        current.compare(target, options: .numeric) == .orderedAscending
    }
}
