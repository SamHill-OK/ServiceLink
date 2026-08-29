//
//  AddElderMeetingGuestViewModel.swift
//  ServiceLink
//
//  Created by Michael Anderson on 6/11/26.
//

import Foundation
import Combine

@MainActor
final class AddElderMeetingGuestViewModel: ObservableObject {

    @Published var session: ServiceLinkSession?

    @Published var searchText = ""
    @Published var memberSearchResults: [MemberLookupDto] = []
    @Published var selectedMember: MemberLookupDto?

    @Published var guestTime = Date()
    @Published var guestNotes = ""

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
            print("❌ meeting guest member search failed:", error)
        }
    }
    func setDefaultGuestTime(from meetingDate: String) {

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

        if let date = formatter.date(from: meetingDate) {
            guestTime = date
        }
    }
    func save(elderMeetingId: Int) async -> Bool {

        guard let session,
              let selectedMember else { return false }

        guard let url = URL(
            string: "\(ApiConfig.baseUrl)/api/eldertools/meeting/guest/add"
        ) else {
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

        let timeFormatter = DateFormatter()
        timeFormatter.locale = Locale(identifier: "en_US_POSIX")
        timeFormatter.dateFormat = "HH:mm:ss"

        let payload: [String: Any] = [
            "elderMeetingId": elderMeetingId,
            "memberId": selectedMember.memberID,
            "guestTime": timeFormatter.string(from: guestTime),
            "guestNotes": guestNotes
        ]
        print("🧪 elderMeetingId:", elderMeetingId)
        print("🧪 memberId:", selectedMember.memberID)
        print("🧪 guestTime:", timeFormatter.string(from: guestTime))
        print("🧪 guestNotes:", guestNotes)
        print("🧪 clientId:", session.clientId)
        print("🧪 userId:", session.memberId)

        do {
            let body = try JSONSerialization.data(withJSONObject: payload)

            print(String(data: body, encoding: .utf8)!)

            request.httpBody = body

            let (data, response) = try await ApiClient.shared.data(for: request)

            guard let http = response as? HTTPURLResponse else {
                return false
            }
            print("🧪 Add guest status:", http.statusCode)
            print("🧪 Add guest response:", String(data: data, encoding: .utf8) ?? "<empty>")
            
            if (200...299).contains(http.statusCode) {
                return true
            }

            if http.statusCode == 409 {
                errorMessage = "This member is already added to this meeting."
            }

            return false

        } catch {
            errorMessage = "Unable to save guest."
            return false
        }
    }
}
