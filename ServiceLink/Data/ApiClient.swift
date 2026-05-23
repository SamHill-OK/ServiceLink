//
//  ApiClient.swift
//  ServiceLink
//
//  Created by Michael Anderson on 5/22/26.
//

import Foundation

final class ApiClient {

    static let shared = ApiClient()

    private init() { }

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
            try await URLSession.shared.data(
                for: request
            )

        guard let http =
            response as? HTTPURLResponse
        else {
            throw URLError(.badServerResponse)
        }

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
        
        
        print(String(data: data, encoding: .utf8) ?? "NO DATA")

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
            try await URLSession.shared.data(
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
            try await URLSession.shared.data(
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
            try await URLSession.shared.data(for: request)

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
            try await URLSession.shared.data(
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
            try await URLSession.shared.data(from: url)

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
            try await URLSession.shared.data(from: url)

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
            try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode)
        else {
            throw URLError(.badServerResponse)
        }
    }
    
}
