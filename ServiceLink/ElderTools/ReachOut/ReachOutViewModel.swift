//
//  ReachOutViewModel.swift
//  ServiceLink
//
//  Created by Michael Anderson on 6/11/26.
//

import Foundation
import Combine

@MainActor
final class ReachOutViewModel: ObservableObject {

    @Published var session: ServiceLinkSession?
    @Published var isLoading = false
    @Published var reachOutMember: ElderNextResult?
    @Published var recentGoForwards: [GoForwardRecentDto] = []

    func configure(session: ServiceLinkSession) {
        self.session = session
    }
    func load() async {

        await loadRecentGoForwards()

        guard let session else { return }

        guard let url = URL(
            string: "\(ApiConfig.baseUrl)/api/eldertools/next"
        ) else {
            return
        }

        isLoading = true
        defer { isLoading = false }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(String(session.clientId), forHTTPHeaderField: "X-ClientID")
        request.setValue(String(session.memberId), forHTTPHeaderField: "X-UserID")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let http = response as? HTTPURLResponse,
                  http.statusCode == 200 else {
                print("❌ ReachOut next failed")
                return
            }

            if data.isEmpty || String(data: data, encoding: .utf8) == "null" {
                reachOutMember = nil
                return
            }

            reachOutMember = try JSONDecoder().decode(ElderNextResult.self, from: data)

        } catch {
            print("❌ ReachOut load failed:", error)
        }
    }
    func markContacted() async -> Bool {

        guard let session,
              let member = reachOutMember else {
            return false
        }

        guard let url = URL(
            string: "\(ApiConfig.baseUrl)/api/eldertools/reachout/mark-contacted"
        ) else {
            return false
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(String(session.clientId), forHTTPHeaderField: "X-ClientID")

        let body = [
            "memberID": member.memberID
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)

            let (_, response) = try await URLSession.shared.data(for: request)

            guard let http = response as? HTTPURLResponse,
                  http.statusCode == 200 else {
                return false
            }

            reachOutMember = nil
            return true

        } catch {
            print("❌ markContacted failed:", error)
            return false
        }
    }
    func loadRecentGoForwards() async {

        guard let session else { return }

        guard let url = URL(
            string: "\(ApiConfig.baseUrl)/api/eldertools/goforward/recent"
        ) else {
            return
        }

        var request = URLRequest(url: url)
        request.setValue(String(session.clientId), forHTTPHeaderField: "X-ClientID")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            print("GoForward Response:")
            print(String(data: data, encoding: .utf8) ?? "NO DATA")

            guard let http = response as? HTTPURLResponse,
                  http.statusCode == 200 else {
                print("❌ loadRecentGoForwards failed")
                return
            }

            recentGoForwards = try JSONDecoder().decode(
                [GoForwardRecentDto].self,
                from: data
            )
            print("Loaded \(recentGoForwards.count) go forwards")

        } catch {
            print("❌ loadRecentGoForwards error:", error)
        }
    }
    func updateGoForward(
        id: Int,
        note: String,
        resolved: Bool
    ) async {

        guard let session else { return }

        guard let url = URL(
            string: "\(ApiConfig.baseUrl)/api/eldertools/goforward/update"
        ) else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(String(session.clientId), forHTTPHeaderField: "X-ClientID")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "goForwardId": id,
            "note": note,
            "resolvedFlag": resolved
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)

            let (_, response) = try await URLSession.shared.data(for: request)

            if (response as? HTTPURLResponse)?.statusCode == 200 {
                await loadRecentGoForwards()
            }

        } catch {
            print("❌ updateGoForward error:", error)
        }
    }
}
