//
//  DirectoryPhotoAccessManager.swift
//  ServiceLink
//
//  Created by Michael Anderson on 9/7/26.
//

import Foundation

actor DirectoryPhotoAccessManager {

    static let shared =
        DirectoryPhotoAccessManager()

    private var cachedAccess:
        DirectoryPhotoAccessResponse?

    private var cachedClientId:
        Int?
    private var cachedUserId:
        Int?

    private init() { }

    func getAccess(
        clientId: Int,
        userId: Int
    ) async throws -> DirectoryPhotoAccessResponse {

        if
            let cachedAccess,
            cachedClientId == clientId,
            cachedUserId == userId,
            !isExpiringSoon(cachedAccess)
        {
            return cachedAccess
        }

        let newAccess =
            try await ApiClient.shared
                .getDirectoryPhotoAccess(
                    clientId: clientId,
                    userId: userId
                )

        cachedAccess =
            newAccess

        cachedClientId =
            clientId

        cachedUserId =
            userId

        return newAccess
    }

    func clear() {

        cachedAccess =
            nil

        cachedClientId =
            nil

        cachedUserId =
            nil
    }

    private func isExpiringSoon(
        _ access: DirectoryPhotoAccessResponse
    ) -> Bool {

        let fractionalFormatter =
            ISO8601DateFormatter()

        fractionalFormatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]

        let standardFormatter =
            ISO8601DateFormatter()

        standardFormatter.formatOptions = [
            .withInternetDateTime
        ]

        guard
            let expiresOn =
                fractionalFormatter.date(
                    from: access.expiresOn
                )
                ?? standardFormatter.date(
                    from: access.expiresOn
                )
        else {
            return true
        }

        let refreshAt =
            expiresOn.addingTimeInterval(
                -5 * 60
            )

        return Date() >= refreshAt
    }
}
