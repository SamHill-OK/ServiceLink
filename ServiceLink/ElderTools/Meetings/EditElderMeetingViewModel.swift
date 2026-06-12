//
//  EditElderMeetingViewModel.swift
//  ServiceLink
//
//  Created by Michael Anderson on 6/12/26.
//

import Foundation
import Combine

@MainActor
final class EditElderMeetingViewModel: ObservableObject {

    @Published var session: ServiceLinkSession?

    func configure(session: ServiceLinkSession) {
        self.session = session
    }

    func updateMeeting(
        meetingId: Int,
        title: String,
        meetingDate: Date,
        notes: String
    ) async -> Bool {

        guard let session else { return false }

        guard let url = URL(
            string: "\(ApiConfig.baseUrl)/api/eldertools/meeting/update"
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

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

        let payload: [String: Any] = [
            "elderMeetingId": meetingId,
            "meetingTitle": title,
            "meetingDate": formatter.string(from: meetingDate),
            "notes": notes
        ]

        do {

            request.httpBody =
                try JSONSerialization.data(
                    withJSONObject: payload
                )

            let (_, response) =
                try await URLSession.shared.data(
                    for: request
                )

            return (response as? HTTPURLResponse)?
                .statusCode == 200

        } catch {

            print("❌ updateMeeting:", error)
            return false
        }
    }
}
