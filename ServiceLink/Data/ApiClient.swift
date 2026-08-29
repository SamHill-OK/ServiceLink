//
//  ApiClient.swift
//  ServiceLink
//
//  Created by Michael Anderson on 5/22/26.
//

import Foundation

enum ApiError: Error, LocalizedError {
    case invalidUrl
    case http(Int, String)
    case decoding(Error)

    var errorDescription: String? {
        switch self {
        case .invalidUrl:
            return "Invalid URL"
        case .http(let code, let body):
            return "Server error (\(code)). \(body)"
        case .decoding(let err):
            return "Decode failed: \(err.localizedDescription)"
        }
    }
}

final class ApiClient {

    static let shared = ApiClient()

    private let session: URLSession

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        return d
    }()

    private let encoder: JSONEncoder = {
        let e = JSONEncoder()
        return e
    }()

    private init() {

        let configuration =
            URLSessionConfiguration.default

        if #available(iOS 18.4, *) {
            configuration.usesClassicLoadingMode = false
        }

        session = URLSession(
            configuration: configuration
        )
    }
    
    func data(
        from url: URL
    ) async throws -> (Data, URLResponse) {
        try await session.data(from: url)
    }

    func data(
        for request: URLRequest
    ) async throws -> (Data, URLResponse) {
        try await session.data(for: request)
    }
    func login(
        email: String,
        password: String
        ) async throws -> LoginResponse {

        guard let url = URL(
            string: "\(ApiConfig.baseUrl)/api/Login/Member"
        ) else {
            throw URLError(.badURL)
        }

        let requestBody = LoginRequest(
            email: email,
            password: password
        )

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )

        request.httpBody =
            try JSONEncoder().encode(requestBody)

        let (data, response) =
            try await session.data(
                for: request
            )

        guard let http =
            response as? HTTPURLResponse
        else {
            throw URLError(.badServerResponse)
        }
            
            let responseText =
                    String(data: data, encoding: .utf8)
                    ?? "NO DATA"

                print("Login status: \(http.statusCode)")
                print("Login response: \(responseText)")
            
        if http.statusCode != 200 {
            throw NSError(
                domain: "",
                code: http.statusCode,
                userInfo: [
                    NSLocalizedDescriptionKey:
                    "Login failed"
                ]
            )
        }

        let decoder = JSONDecoder()
        
        
        //print(String(data: data, encoding: .utf8) ?? "NO DATA")

        return try decoder.decode(LoginResponse.self, from: data)
    }
    
    func getAssignments(
        clientId: Int,
        memberId: Int
        ) async throws -> [ServiceLinkAssignment] {

        guard let url =
            URL(
                string:
                "\(ApiConfig.baseUrl)/api/ServiceLink/Assignments?clientId=\(clientId)&memberId=\(memberId)"
            )
        else {
            throw URLError(.badURL)
        }

        let (data, _) =
            try await session.data(
                from: url
            )

        return try JSONDecoder()
            .decode(
                [ServiceLinkAssignment].self,
                from: data
            )
    }
    func getAssignmentsForMember(
        clientId: Int,
        memberId: Int
    ) async throws -> [ServiceLinkAssignment] {

        guard let url =
            URL(
                string:
                "\(ApiConfig.baseUrl)/api/ServiceLink/AssignmentsForMember?clientId=\(clientId)&memberId=\(memberId)"
            )
        else {
            throw URLError(.badURL)
        }

        let (data, response) =
            try await session.data(
                from: url
            )

      

       

        let responseText =
            String(data: data, encoding: .utf8)
            ?? "No readable response"

       

        return try JSONDecoder()
            .decode(
                [ServiceLinkAssignment].self,
                from: data
            )
    }
    func declineAssignment(
        id: Int,
        clientId: Int,
        memberId: Int
    ) async throws {

        guard let url = URL(
            string: "\(ApiConfig.baseUrl)/api/ServiceLink/DeclineAssignment"
        ) else {
            throw URLError(.badURL)
        }

        let body = DeclineAssignmentRequest(
            id: id,
            clientId: clientId,
            memberId: memberId
        )

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )

        request.httpBody = try JSONEncoder().encode(body)

        let (_, response) =
            try await session.data(for: request)

        guard let http = response as? HTTPURLResponse,
              http.statusCode == 200
        else {
            throw URLError(.badServerResponse)
        }
    }
    
    func respondAssignment(
        id: Int,
        clientId: Int,
        memberId: Int,
        reply: String
    ) async throws {

        guard let url =
            URL(
                string:
                "\(ApiConfig.baseUrl)/api/ServiceLink/RespondAssignment"
            )
        else {
            throw URLError(.badURL)
        }

        let body: [String: Any] = [
            "id": id,
            "clientId": clientId,
            "memberId": memberId,
            "reply": reply
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )
        request.httpBody =
            try JSONSerialization.data(
                withJSONObject: body
            )

        let (_, response) =
            try await session.data(
                for: request
            )

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode)
        else {
            throw URLError(.badServerResponse)
        }
    }
    func getTaskChoiceMembers(
        clientId: Int,
        memberId: Int
    ) async throws -> [ServiceLinkTaskChoiceMember] {

        guard let url = URL(
            string:
            "\(ApiConfig.baseUrl)/api/servicelink/task-choices/members?clientId=\(clientId)&memberId=\(memberId)"
        ) else {
            throw URLError(.badURL)
        }

        let (data, response) =
            try await session.data(from: url)

        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode)
        else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder()
            .decode(
                [ServiceLinkTaskChoiceMember].self,
                from: data
            )
    }

    func getTaskChoices(
        clientId: Int,
        memberId: Int
    ) async throws -> [ServiceLinkTaskChoice] {

        guard let url = URL(
            string:
            "\(ApiConfig.baseUrl)/api/servicelink/task-choices?clientId=\(clientId)&memberId=\(memberId)"
        ) else {
            throw URLError(.badURL)
        }

        let (data, response) =
            try await session.data(from: url)

        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode)
        else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder()
            .decode(
                [ServiceLinkTaskChoice].self,
                from: data
            )
    }

    func requestTaskChoice(
        clientId: Int,
        memberId: Int,
        worshipId: Int,
        onFlag: Bool
    ) async throws {

        guard let url = URL(
            string:
            "\(ApiConfig.baseUrl)/api/servicelink/task-choices/request"
        ) else {
            throw URLError(.badURL)
        }

        let body = ServiceLinkTaskChoiceRequest(
            clientId: clientId,
            memberId: memberId,
            worshipId: worshipId,
            onFlag: onFlag
        )

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )
        request.httpBody = try JSONEncoder().encode(body)

        let (_, response) =
            try await session.data(for: request)

        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode)
        else {
            throw URLError(.badServerResponse)
        }
    }
    func forgotPassword(
        email: String
    ) async throws {

        guard let url = URL(
            string:
            "\(ApiConfig.baseUrl)/api/Login/ForgotPassword"
        ) else {
            throw URLError(.badURL)
        }

        let body = [
            "email": email,
            "source": "servicelink"
        ]

        var request = URLRequest(url: url)

        request.httpMethod = "POST"

        request.setValue(
            "application/json",
            forHTTPHeaderField:
                "Content-Type"
        )

        request.httpBody =
            try JSONSerialization.data(
                withJSONObject: body
            )

        let (_, response) =
            try await session.data(
                for: request
            )

        guard let http =
            response as? HTTPURLResponse,
              (200...299)
                .contains(
                    http.statusCode
                )
        else {
            throw URLError(
                .badServerResponse
            )
        }
    }

    func requestServiceLinkAccount(
        email: String
    ) async throws {

        guard let url = URL(
            string:
            "\(ApiConfig.baseUrl)/api/ServiceLinkAccount/RequestServiceLinkAccount"
        ) else {
            throw URLError(.badURL)
        }

        let body = [
            "email": email
        ]

        var request = URLRequest(url: url)

        request.httpMethod = "POST"

        request.setValue(
            "application/json",
            forHTTPHeaderField:
                "Content-Type"
        )

        request.httpBody =
            try JSONSerialization.data(
                withJSONObject: body
            )

        let (_, response) =
            try await session.data(
                for: request
            )

        guard let http =
            response as? HTTPURLResponse,
              (200...299)
                .contains(
                    http.statusCode
                )
        else {
            throw URLError(
                .badServerResponse
            )
        }
    }
    
    //----------------------
    private func buildUrl(_ path: String, query: [URLQueryItem]) throws -> URL {
        guard var comps = URLComponents(string: "\(ApiConfig.baseUrl)\(path)") else {
            throw ApiError.invalidUrl
        }
        if !query.isEmpty { comps.queryItems = query }
        guard let url = comps.url else { throw ApiError.invalidUrl }
        return url
    }
    private func validate(resp: URLResponse, data: Data) throws {
        guard let http = resp as? HTTPURLResponse else { return }
        guard (200...299).contains(http.statusCode) else {
            let body = String(decoding: data, as: UTF8.self)
            throw ApiError.http(http.statusCode, body)
        }
    }
    
    func getEotmElders(clientId: Int) async throws -> [EotmElderOptionDto] {
        let url = try buildUrl(
            "/api/Eotm/elders",
            query: [
                URLQueryItem(name: "clientId", value: String(clientId))
            ]
        )

        var req = URLRequest(url: url)
        req.httpMethod = "GET"

        let (data, resp) = try await session.data(for: req)
        try validate(resp: resp, data: data)

        

        do { return try decoder.decode([EotmElderOptionDto].self, from: data) }
        catch { throw ApiError.decoding(error) }
    }

    func replaceEotm(clientId: Int, eotmId: Int, newElderId: Int) async throws {
        let query = [
            URLQueryItem(name: "clientId", value: String(clientId)),
            URLQueryItem(name: "eotmId", value: String(eotmId)),
            URLQueryItem(name: "newElderId", value: String(newElderId))
        ]

        let url = try buildUrl("/api/Eotm/replace-elder", query: query)

        var req = URLRequest(url: url)
        req.httpMethod = "PUT"

        let (data, resp) = try await session.data(for: req)
        try validate(resp: resp, data: data)
    }
    
    func swapEotm(clientId: Int, firstEotmId: Int, secondEotmId: Int) async throws {
        let url = try buildUrl("/api/Eotm/swap", query: [])

        let body: [String: Any] = [
            "clientId": clientId,
            "firstEotmId": firstEotmId,
            "secondEotmId": secondEotmId
        ]

        var req = URLRequest(url: url)
        req.httpMethod = "PUT"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, resp) = try await session.data(for: req)
        try validate(resp: resp, data: data)
    }
    func getMeetingNote(
        clientId: Int,
        userId: Int,
        elderMeetingId: Int,
        noteType: MeetingNoteType
    ) async throws -> ElderMeetingNoteDto? {
        let url = try buildUrl("/api/eldertools/meeting/\(elderMeetingId)/note/\(noteType.rawValue)", query: [])

        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue(String(clientId), forHTTPHeaderField: "X-ClientID")
        req.setValue(String(userId), forHTTPHeaderField: "X-UserID")

        let (data, resp) = try await session.data(for: req)

        if let http = resp as? HTTPURLResponse {

            print("📌 getElderMeetingNote Status: \(http.statusCode)")

            if let body = String(data: data, encoding: .utf8) {
                print("📌 Response Body:")
                print(body)
            }

            if http.statusCode == 204 {
                return nil
            }
        }

        try validate(resp: resp, data: data)

        do {
            return try decoder.decode(ElderMeetingNoteDto.self, from: data)
        } catch {
            throw ApiError.decoding(error)
        }
    }
    func saveMeetingNote(
        clientId: Int,
        userId: Int,
        elderMeetingId: Int,
        noteType: MeetingNoteType,
        noteTitle: String?,
        noteMarkdown: String
    ) async throws {
        let url = try buildUrl("/api/eldertools/meeting/\(elderMeetingId)/note/\(noteType.rawValue)", query: [])

        let body = SaveElderMeetingNoteRequest(
            noteTitle: noteTitle,
            noteMarkdown: noteMarkdown
        )

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue(String(clientId), forHTTPHeaderField: "X-ClientID")
        req.setValue(String(userId), forHTTPHeaderField: "X-UserID")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try encoder.encode(body)

        let (data, resp) = try await session.data(for: req)
        try validate(resp: resp, data: data)
    }
    func deleteMeetingNote(
        clientId: Int,
        userId: Int,
        elderMeetingId: Int,
        noteType: MeetingNoteType
    ) async throws {
        let url = try buildUrl("/api/eldertools/meeting/\(elderMeetingId)/note/\(noteType.rawValue)/delete", query: [])

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue(String(clientId), forHTTPHeaderField: "X-ClientID")
        req.setValue(String(userId), forHTTPHeaderField: "X-UserID")

        let (data, resp) = try await session.data(for: req)
        
        try validate(resp: resp, data: data)
    }
    func getEotmList(
        clientId: Int
    ) async throws -> [EotmDto] {

        guard let url = URL(
            string:
            "\(ApiConfig.baseUrl)/api/Eotm?clientId=\(clientId)"
        ) else {
            throw URLError(.badURL)
        }

        let (data, response) =
            try await session.data(
                from: url
            )

        guard let http =
            response as? HTTPURLResponse,
              (200...299).contains(http.statusCode)
        else {
            throw URLError(.badServerResponse)
        }

        return try decoder.decode(
            [EotmDto].self,
            from: data
        )
    }
    func getDirectoryStaff(
        clientId: Int,
        activeOnly: Bool = true
    ) async throws -> [DirectoryStaffMember] {

        let url = try buildUrl(
            "/api/DirectoryStaff",
            query: [
                URLQueryItem(
                    name: "clientId",
                    value: String(clientId)
                ),
                URLQueryItem(
                    name: "activeOnly",
                    value: String(activeOnly)
                )
            ]
        )

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let (data, response) =
            try await session.data(for: request)

        try validate(
            resp: response,
            data: data
        )

        do {
            return try decoder.decode(
                [DirectoryStaffMember].self,
                from: data
            )
        } catch {
            throw ApiError.decoding(error)
        }
    }
    func getDirectoryFamily(
        clientId: Int,
        wspFamilyId: Int
    ) async throws -> DirectoryFamilyDetail {

        let url = try buildUrl(
            "/api/Family/\(wspFamilyId)",
            query: [
                URLQueryItem(
                    name: "clientId",
                    value: String(clientId)
                )
            ]
        )

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let (data, response) =
            try await session.data(for: request)

        try validate(
            resp: response,
            data: data
        )

        let decoder = JSONDecoder()

        decoder.dateDecodingStrategy = .custom { decoder in

            let container =
                try decoder.singleValueContainer()

            let value =
                try container.decode(String.self)

            let formats = [
                "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS",
                "yyyy-MM-dd'T'HH:mm:ss.SSSSSS",
                "yyyy-MM-dd'T'HH:mm:ss.SSS",
                "yyyy-MM-dd'T'HH:mm:ss",
                "yyyy-MM-dd"
            ]

            for format in formats {

                let formatter = DateFormatter()
                formatter.locale =
                    Locale(identifier: "en_US_POSIX")
                formatter.dateFormat = format

                if let date = formatter.date(from: value) {
                    return date
                }
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription:
                    "Unable to decode date: \(value)"
            )
        }

        do {
            return try decoder.decode(
                DirectoryFamilyDetail.self,
                from: data
            )
        } catch {
            throw ApiError.decoding(error)
        }
    }
    func searchDirectoryFamilies(
        clientId: Int,
        searchText: String? = nil,
        activeOnly: Bool = true
    ) async throws -> [DirectoryFamily] {

        var queryItems = [
            URLQueryItem(
                name: "clientId",
                value: String(clientId)
            ),
            URLQueryItem(
                name: "activeOnly",
                value: String(activeOnly)
            )
        ]

        if let searchText,
           !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {

            queryItems.append(
                URLQueryItem(
                    name: "searchText",
                    value: searchText
                )
            )
        }

        let url = try buildUrl(
            "/api/Family/search",
            query: queryItems
        )

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let (data, response) =
            try await session.data(for: request)

        try validate(
            resp: response,
            data: data
        )

        do {
            return try decoder.decode(
                [DirectoryFamily].self,
                from: data
            )
        } catch {
            throw ApiError.decoding(error)
        }
    }
}
