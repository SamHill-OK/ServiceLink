//
//  ElderMeetingDetailViewModel.swift
//  ServiceLink
//
//  Created by Michael Anderson on 6/11/26.
//

import Foundation
import Combine

@MainActor
final class ElderMeetingDetailViewModel: ObservableObject {

    @Published var session: ServiceLinkSession?
    @Published var meeting: ElderMeetingDetailDto?
    @Published var isLoading = false
    @Published var errorMessage: String?

    func configure(session: ServiceLinkSession) {
        self.session = session
    }
    func loadMeeting(elderMeetingId: Int) async {

        guard let session else { return }

        guard let url = URL(
            string: "\(ApiConfig.baseUrl)/api/eldertools/meeting/\(elderMeetingId)"
        ) else {
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        var request = URLRequest(url: url)
        request.setValue(String(session.clientId), forHTTPHeaderField: "X-ClientID")
        request.setValue(String(session.memberId), forHTTPHeaderField: "X-UserID")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let http = response as? HTTPURLResponse,
                  http.statusCode == 200 else {
                errorMessage = "Unable to load meeting."
                return
            }

            meeting = try JSONDecoder().decode(
                ElderMeetingDetailDto.self,
                from: data
            )

        } catch {
            print("❌ loadMeeting error:", error)
            errorMessage = "Unable to load meeting."
        }
    }
    func cancelMeeting(elderMeetingId: Int) async -> Bool {

        guard let session else { return false }

        guard let url = URL(
            string: "\(ApiConfig.baseUrl)/api/eldertools/meeting/cancel"
        ) else {
            return false
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(String(session.clientId), forHTTPHeaderField: "X-ClientID")
        request.setValue(String(session.memberId), forHTTPHeaderField: "X-UserID")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "elderMeetingId": elderMeetingId,
            "cancelReason": "Canceled from ServiceLink"
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)

            let (_, response) = try await URLSession.shared.data(for: request)

            return (response as? HTTPURLResponse)?.statusCode == 200

        } catch {
            print("❌ cancelMeeting failed:", error)
            return false
        }
    }
    func removeGuest(elderMeetingGuestId: Int) async -> Bool {

        guard let session else { return false }

        guard let url = URL(
            string: "\(ApiConfig.baseUrl)/api/eldertools/meeting/guest/remove"
        ) else {
            return false
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(String(session.clientId), forHTTPHeaderField: "X-ClientID")
        request.setValue(String(session.memberId), forHTTPHeaderField: "X-UserID")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "elderMeetingGuestId": elderMeetingGuestId
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)

            let (_, response) = try await URLSession.shared.data(for: request)

            return (response as? HTTPURLResponse)?.statusCode == 200

        } catch {
            print("❌ removeGuest failed:", error)
            return false
        }
    }
}
