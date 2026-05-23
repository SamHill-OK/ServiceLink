//
//  AuthModels.swift
//  ServiceLink
//
//  Created by Michael Anderson on 5/22/26.
//

import Foundation

struct ServiceLinkSession: Codable {
    let memberId: Int
    let memberName: String

    let clientId: Int
    let clientName: String

    let roleId: Int

    let token: String
    let allowPublicTaskRequests: Bool
}
