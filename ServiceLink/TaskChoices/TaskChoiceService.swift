//
//  TaskChoiceService.swift
//  ServiceLink
//
//  Created by Michael Anderson on 5/23/26.
//

import Foundation

final class TaskChoiceService {
    static let shared = TaskChoiceService()
    private init() {}

    private let baseUrl = ApiConfig.baseUrl

    func getMembers(clientId: Int, memberId: Int) async throws -> [ServiceLinkTaskChoiceMember] {
        let url = URL(string: "\(baseUrl)/api/servicelink/task-choices/members?clientId=\(clientId)&memberId=\(memberId)")!

        let (data, response) = try await ApiClient.shared.data(from: url)
        try validate(response)

        return try JSONDecoder().decode([ServiceLinkTaskChoiceMember].self, from: data)
    }

    func getTaskChoices(clientId: Int, memberId: Int) async throws -> [ServiceLinkTaskChoice] {
        let url = URL(string: "\(baseUrl)/api/servicelink/task-choices?clientId=\(clientId)&memberId=\(memberId)")!

        let (data, response) = try await ApiClient.shared.data(from: url)
        try validate(response)

        return try JSONDecoder().decode([ServiceLinkTaskChoice].self, from: data)
    }

    func requestChoice(_ request: ServiceLinkTaskChoiceRequest) async throws {
        let url = URL(string: "\(baseUrl)/api/servicelink/task-choices/request")!

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)

        let (_, response) = try await ApiClient.shared.data(for: urlRequest)
        try validate(response)
    }

    private func validate(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
}
