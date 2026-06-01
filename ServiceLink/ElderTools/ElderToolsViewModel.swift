import Foundation
import Combine

@MainActor
final class ElderToolsViewModel: ObservableObject {

    @Published var session: ServiceLinkSession?

    @Published var reachOutMember: ElderNextResult?
    @Published var isLoadingReachOut = false

    @Published var recentGoForwards: [GoForwardRecentDto] = []
    @Published var memberSearchResults: [MemberLookupDto] = []

    @Published var eotmList: [EotmDto] = []
    @Published var eotmElders: [EotmElderOptionDto] = []
    
    @Published var meetings: [ElderMeetingDto] = []

    @Published var selectedMeeting: ElderMeetingDetailDto?

    @Published var isLoadingMeetings = false
    @Published var isShowingCreateMeeting = false
    
    func configure(session: ServiceLinkSession) {
        self.session = session
    }

    // MARK: - Reach Out

    func loadNextReachOut() async {
        guard let session else { return }

        guard let url = URL(string: "\(ApiConfig.baseUrl)/api/eldertools/next") else {
            return
        }

        isLoadingReachOut = true
        defer { isLoadingReachOut = false }

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

            if data.isEmpty {
                reachOutMember = nil
                return
            }

            reachOutMember = try JSONDecoder().decode(ElderNextResult.self, from: data)

        } catch {
            print("❌ ReachOut error:", error)
        }
    }

    func markReachOutContacted() async {
        guard let session,
              let member = reachOutMember else { return }

        guard let url = URL(string: "\(ApiConfig.baseUrl)/api/eldertools/reachout/mark-contacted") else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(String(session.clientId), forHTTPHeaderField: "X-ClientID")

        let body = ["memberID": member.memberID]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        do {
            let (_, response) = try await URLSession.shared.data(for: request)

            guard let http = response as? HTTPURLResponse,
                  http.statusCode == 200 else {
                print("❌ Mark contacted failed")
                return
            }

            reachOutMember = nil

        } catch {
            print("❌ Mark contacted error:", error)
        }
    }

    // MARK: - Go Forward

    func loadRecentGoForwards() async {
        guard let session else { return }

        guard let url = URL(string: "\(ApiConfig.baseUrl)/api/eldertools/goforward/recent") else {
            return
        }

        var request = URLRequest(url: url)
        request.setValue("\(session.clientId)", forHTTPHeaderField: "X-ClientID")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard (response as? HTTPURLResponse)?.statusCode == 200 else { return }

            let decoder = JSONDecoder()
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS"

            decoder.dateDecodingStrategy = .formatted(formatter)

            recentGoForwards = try decoder.decode([GoForwardRecentDto].self, from: data)

        } catch {
            print("❌ loadRecentGoForwards error:", error)
        }
    }

    func addGoForward(memberId: Int, note: String) async -> Bool {
        guard let session else { return false }

        guard let url = URL(string: "\(ApiConfig.baseUrl)/api/eldertools/goforward") else {
            return false
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("\(session.clientId)", forHTTPHeaderField: "X-ClientID")
        request.setValue("\(session.memberId)", forHTTPHeaderField: "X-UserID")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "memberId": memberId,
            "note": note
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
            let (_, response) = try await URLSession.shared.data(for: request)

            return (response as? HTTPURLResponse)?.statusCode == 200
        } catch {
            print("Add go-forward error:", error)
            return false
        }
    }

    func updateGoForward(id: Int, note: String, resolved: Bool) async {
        guard let session else { return }

        guard let url = URL(string: "\(ApiConfig.baseUrl)/api/eldertools/goforward/update") else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("\(session.clientId)", forHTTPHeaderField: "X-ClientID")
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
            print("Update error:", error)
        }
    }

    func searchMembers(query: String) async {
        guard let session else { return }

        if query.count < 2 {
            memberSearchResults = []
            return
        }

        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        guard let url = URL(string: "\(ApiConfig.baseUrl)/api/eldertools/memberlookup/search?query=\(encoded)") else {
            return
        }

        var request = URLRequest(url: url)
        request.setValue("\(session.clientId)", forHTTPHeaderField: "X-ClientID")

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            memberSearchResults = try JSONDecoder().decode([MemberLookupDto].self, from: data)
        } catch {
            print("Search error:", error)
        }
    }

    // MARK: - EOTM

    func loadEotmList() async {
        guard let session else { return }

        guard let url = URL(string: "\(ApiConfig.baseUrl)/api/Eotm?clientId=\(session.clientId)") else {
            return
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard (response as? HTTPURLResponse)?.statusCode == 200 else { return }

            let items = try JSONDecoder().decode([EotmDto].self, from: data)

            let now = Date()
            let components = Calendar.current.dateComponents([.year, .month], from: now)

            eotmList = items.filter { item in
                guard let year = components.year,
                      let month = components.month,
                      let itemMonth = item.calMonth else { return false }

                return item.calYear > year ||
                    (item.calYear == year && itemMonth >= month)
            }

        } catch {
            print("❌ loadEotmList error:", error)
        }
    }

    func loadEotmElders() async {
        guard let session else { return }

        do {
            eotmElders = try await ApiClient.shared.getEotmElders(clientId: session.clientId)
        } catch {
            print("❌ loadEotmElders failed:", error.localizedDescription)
            eotmElders = []
        }
    }

    func replaceEotm(eotmId: Int, newElderId: Int) async {
        guard let session else { return }

        do {
            try await ApiClient.shared.replaceEotm(
                clientId: session.clientId,
                eotmId: eotmId,
                newElderId: newElderId
            )

            await loadEotmList()

        } catch {
            print("❌ replaceEotm failed:", error.localizedDescription)
        }
    }

    func swapEotm(firstId: Int, secondId: Int) async {
        guard let session else { return }

        do {
            try await ApiClient.shared.swapEotm(
                clientId: session.clientId,
                firstEotmId: firstId,
                secondEotmId: secondId
            )

            await loadEotmList()

        } catch {
            print("❌ swapEotm failed:", error.localizedDescription)
        }
    }
    
    // MARK: - Elders Meetings
    func loadMeetings() async {
        guard let session else { return }

        guard let url = URL(
            string: "\(ApiConfig.baseUrl)/api/eldertools/meeting/future"
        ) else {
            return
        }

        isLoadingMeetings = true
        defer { isLoadingMeetings = false }

        var request = URLRequest(url: url)

        request.setValue(
            "\(session.clientId)",
            forHTTPHeaderField: "X-ClientID"
        )

        request.setValue(
            "\(session.memberId)",
            forHTTPHeaderField: "X-UserID"
        )

        do {

            let (data, response) =
                try await URLSession.shared.data(
                    for: request
                )

            guard (response as? HTTPURLResponse)?
                .statusCode == 200 else {
                return
            }

            let decoder = elderMeetingDecoder()

            meetings = try decoder.decode(
                [ElderMeetingDto].self,
                from: data
            )

        } catch {

            print("❌ loadMeetings:", error)

        }
    }
    
    private func elderMeetingDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()

        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let value = try container.decode(String.self)

            let formats = [
                "yyyy-MM-dd'T'HH:mm:ss.SSS",
                "yyyy-MM-dd'T'HH:mm:ss"
            ]

            for format in formats {
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "en_US_POSIX")
                formatter.dateFormat = format

                if let date = formatter.date(from: value) {
                    return date
                }
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid date: \(value)"
            )
        }

        return decoder
    }
    func loadMeetingDetail(meetingId: Int) async {
        guard let session else { return }

        guard let url = URL(
            string: "\(ApiConfig.baseUrl)/api/eldertools/meeting/\(meetingId)"
        ) else {
            return
        }

        var request = URLRequest(url: url)
        request.setValue("\(session.clientId)", forHTTPHeaderField: "X-ClientID")
        request.setValue("\(session.memberId)", forHTTPHeaderField: "X-UserID")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                print("❌ loadMeetingDetail failed")
                return
            }

            let decoder = elderMeetingDecoder()

            selectedMeeting = try decoder.decode(
                ElderMeetingDetailDto.self,
                from: data
            )

        } catch {
            print("❌ loadMeetingDetail:", error)
        }
    }
    func createMeeting(
        title: String,
        meetingDate: Date,
        notes: String
    ) async -> Bool {
        guard let session else { return false }

        guard let url = URL(
            string: "\(ApiConfig.baseUrl)/api/eldertools/meeting/create"
        ) else {
            return false
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("\(session.clientId)", forHTTPHeaderField: "X-ClientID")
        request.setValue("\(session.memberId)", forHTTPHeaderField: "X-UserID")
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

            let (_, response) = try await URLSession.shared.data(for: request)

            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                return false
            }

            await loadMeetings()
            return true

        } catch {
            print("❌ createMeeting:", error)
            return false
        }
    }
    func updateMeeting(
        meetingId: Int,
        title: String,
        meetingDate: Date,
        notes: String
    ) async -> Bool {
        guard let session else { return false }

        guard let url = URL(string: "\(ApiConfig.baseUrl)/api/eldertools/meeting/update") else {
            return false
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("\(session.clientId)", forHTTPHeaderField: "X-ClientID")
        request.setValue("\(session.memberId)", forHTTPHeaderField: "X-UserID")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

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
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)

            let (_, response) = try await URLSession.shared.data(for: request)

            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                return false
            }

            await loadMeetings()
            await loadMeetingDetail(meetingId: meetingId)

            return true

        } catch {
            print("❌ updateMeeting:", error)
            return false
        }
    }
    func cancelMeeting(
        meetingId: Int,
        reason: String
    ) async -> Bool {
        guard let session else { return false }

        guard let url = URL(string: "\(ApiConfig.baseUrl)/api/eldertools/meeting/cancel") else {
            return false
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("\(session.clientId)", forHTTPHeaderField: "X-ClientID")
        request.setValue("\(session.memberId)", forHTTPHeaderField: "X-UserID")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "elderMeetingId": meetingId,
            "cancelReason": reason
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)

            let (_, response) = try await URLSession.shared.data(for: request)

            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                return false
            }

            await loadMeetings()
            

            return true

        } catch {
            print("❌ cancelMeeting:", error)
            return false
        }
    }
    
}
