//
//  SessionStore.swift
//  ServiceLink
//
//  Created by Michael Anderson on 5/22/26.
//

import Foundation

final class SessionStore {

    static let shared = SessionStore()

    private let key =
        "ServiceLinkSession"

    private init() { }

    func save(
        session: ServiceLinkSession
    ) {

        if let data =
            try? JSONEncoder()
                .encode(session)
        {
            UserDefaults.standard
                .set(
                    data,
                    forKey: key
                )
        }
    }

    func load()
    -> ServiceLinkSession? {

        guard let data =
            UserDefaults.standard
                .data(
                    forKey: key
                )
        else {
            return nil
        }

        return try?
            JSONDecoder()
                .decode(
                    ServiceLinkSession.self,
                    from: data
                )
    }

    func clear() {

        UserDefaults.standard
            .removeObject(
                forKey: key
            )
    }
}
