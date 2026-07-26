//
//  ElderMeetingListViewModel.swift
//  ServiceLink
//
//  Created by Michael Anderson on 6/11/26.
//

import Foundation
import Combine

enum MeetingListType {
    case future
    case past
}


@MainActor
final class ElderMeetingListViewModel: ObservableObject {

    @Published var session: ServiceLinkSession?
    @Published var meetings: [ElderMeetingDto] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func configure(session: ServiceLinkSession) {
        self.session = session
    }
    
    func loadMeetings(type: MeetingListType = .future) async {

        guard let session else { return }

        // Do not allow overlapping URLSession requests.
        guard !isLoading else {
            print("⚠️ loadMeetings skipped — already loading")
            return
        }

        let endpoint: String

        switch type {
        case .future:
            endpoint = "future"
        case .past:
            endpoint = "past"
        }

        guard let url = URL(
            string: "\(ApiConfig.baseUrl)/api/eldertools/meeting/\(endpoint)"
        ) else {
            errorMessage = "Invalid meeting URL."
            return
        }

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        var request = URLRequest(url: url)
        request.setValue(
            String(session.clientId),
            forHTTPHeaderField: "X-ClientID"
        )
        request.setValue(
            String(session.memberId),
            forHTTPHeaderField: "X-UserID"
        )

        do {
            let (data, response) =
                try await ApiClient.shared.data(for: request)

            guard let http = response as? HTTPURLResponse,
                  http.statusCode == 200 else {

                errorMessage = "Unable to load meetings."
                return
            }

            meetings = try JSONDecoder().decode(
                [ElderMeetingDto].self,
                from: data
            )

        } catch is CancellationError {

            print("Meeting request cancelled.")

        } catch {

            print("❌ loadMeetings error:", error)
            errorMessage = "Unable to load meetings."
        }
    }
    
}
