//
//  CreateElderMeetingViewModel.swift
//  ServiceLink
//
//  Created by Michael Anderson on 6/11/26.
//

import Foundation
import Combine

@MainActor
final class CreateElderMeetingViewModel: ObservableObject {

    @Published var session: ServiceLinkSession?
    @Published var title = ""
    @Published var meetingDate = Date()
    @Published var notes = ""
    @Published var isSaving = false

    func configure(session: ServiceLinkSession) {
        self.session = session
    }
    func save() async -> Bool {
        guard let session else { return false }

        guard let url = URL(
            string: "\(ApiConfig.baseUrl)/api/eldertools/meeting/create"
        ) else {
            return false
        }

        isSaving = true
        defer { isSaving = false }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(String(session.clientId), forHTTPHeaderField: "X-ClientID")
        request.setValue(String(session.memberId), forHTTPHeaderField: "X-UserID")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

        let payload: [String: Any] = [
            "meetingTitle": title,
            "meetingDate": formatter.string(from: meetingDate),
            "notes": notes
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)

            let (_, response) = try await ApiClient.shared.data(for: request)

            return (response as? HTTPURLResponse)?.statusCode == 200

        } catch {
            print("❌ create meeting failed:", error)
            return false
        }
    }
}
