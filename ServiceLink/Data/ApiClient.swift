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
}
