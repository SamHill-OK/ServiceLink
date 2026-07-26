//
//  GoForwardViewModel.swift
//  ServiceLink
//
//  Created by Michael Anderson on 6/11/26.
//

import Foundation
import Combine

@MainActor
final class GoForwardViewModel: ObservableObject {

    @Published var session: ServiceLinkSession?
    @Published var searchText = ""
    @Published var memberSearchResults: [MemberLookupDto] = []
    @Published var selectedMember: MemberLookupDto?
    @Published var note = ""
    @Published var isSaving = false
    @Published var errorMessage: String?

    func configure(session: ServiceLinkSession) {
        self.session = session
    }
    func searchMembers(query: String) async {

        guard let session else { return }

        if query.count < 2 {
            memberSearchResults = []
            return
        }

        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        guard let url = URL(
            string: "\(ApiConfig.baseUrl)/api/eldertools/memberlookup/search?query=\(encoded)"
        ) else {
            return
        }

        var request = URLRequest(url: url)
        request.setValue(String(session.clientId), forHTTPHeaderField: "X-ClientID")

        do {
            let (data, response) = try await ApiClient.shared.data(for: request)

            guard let http = response as? HTTPURLResponse,
                  http.statusCode == 200 else {
                return
            }

            memberSearchResults = try JSONDecoder().decode(
                [MemberLookupDto].self,
                from: data
            )

        } catch {
            print("❌ member search failed:", error)
        }
    }
    func save() async -> Bool {
        guard let session,
              let selectedMember else { return false }

        guard let url = URL(string: "\(ApiConfig.baseUrl)/api/eldertools/goforward") else {
            return false
        }

        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(String(session.clientId), forHTTPHeaderField: "X-ClientID")
        request.setValue(String(session.memberId), forHTTPHeaderField: "X-UserID")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "memberId": selectedMember.memberID,
            "note": note.trimmingCharacters(in: .whitespacesAndNewlines)
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
            let (_, response) = try await ApiClient.shared.data(for: request)

            guard let http = response as? HTTPURLResponse else { return false }

            if http.statusCode == 200 {
                searchText = ""
                self.selectedMember = nil
                note = ""
                memberSearchResults = []
                return true
            }

            if http.statusCode == 409 {
                errorMessage = "This member was already added today."
            }

            return false

        } catch {
            errorMessage = "Unable to save follow-up."
            return false
        }
    }
}
