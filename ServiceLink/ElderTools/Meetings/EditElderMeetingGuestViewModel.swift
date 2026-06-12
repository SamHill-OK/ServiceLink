//
//  EditElderMeetingGuestViewModel.swift
//  ServiceLink
//
//  Created by Michael Anderson on 6/12/26.
//

import Foundation
import Combine

@MainActor
final class EditElderMeetingGuestViewModel: ObservableObject {

    @Published var session: ServiceLinkSession?

    func configure(session: ServiceLinkSession) {
        self.session = session
    }

    func updateMeetingGuest(
        elderMeetingGuestId: Int,
        guestTime: Date?,
        guestNotes: String
    ) async -> Bool {

        guard let session else { return false }

        guard let url = URL(
            string: "\(ApiConfig.baseUrl)/api/eldertools/meeting/guest/update"
        ) else {
            return false
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        request.setValue(
            String(session.clientId),
            forHTTPHeaderField: "X-ClientID"
        )

        request.setValue(
            String(session.memberId),
            forHTTPHeaderField: "X-UserID"
        )

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )

        let timeFormatter = DateFormatter()
        timeFormatter.locale = Locale(identifier: "en_US_POSIX")
        timeFormatter.dateFormat = "HH:mm:ss"

        let payload: [String: Any] = [
            "elderMeetingGuestId": elderMeetingGuestId,
            "guestTime": timeFormatter.string(from: guestTime ?? Date()),
            "guestNotes": guestNotes
        ]

        do {
            request.httpBody = try JSONSerialization.data(
                withJSONObject: payload
            )

            let (_, response) = try await URLSession.shared.data(
                for: request
            )

            return (response as? HTTPURLResponse)?.statusCode == 200

        } catch {
            print("❌ updateMeetingGuest:", error)
            return false
        }
    }
}
