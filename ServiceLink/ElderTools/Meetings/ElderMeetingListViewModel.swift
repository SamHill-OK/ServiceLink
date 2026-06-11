//
//  ElderMeetingListViewModel.swift
//  ServiceLink
//
//  Created by Michael Anderson on 6/11/26.
//

import Foundation
import Combine

@MainActor
final class ElderMeetingListViewModel: ObservableObject {

    @Published var session: ServiceLinkSession?
    @Published var meetings: [ElderMeetingDto] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func configure(session: ServiceLinkSession) {
        self.session = session
    }
    
    func loadMeetings() async {

        guard let session else { return }

        guard let url = URL(
            string: "\(ApiConfig.baseUrl)/api/eldertools/meeting/future"
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

            print("Meeting Response:")
            print(String(data: data, encoding: .utf8) ?? "NO DATA")

            guard let http = response as? HTTPURLResponse,
                  http.statusCode == 200 else {
                errorMessage = "Unable to load meetings."
                return
            }

            meetings = try JSONDecoder().decode([ElderMeetingDto].self, from: data)

        } catch {
            print("❌ loadMeetings error:", error)
            errorMessage = "Unable to load meetings."
        }
    }
    
}
