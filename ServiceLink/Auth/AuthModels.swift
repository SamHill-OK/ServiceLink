//
//  AuthModels.swift
//  ServiceLink
//
//  Created by Michael Anderson on 5/22/26.
//

import Foundation

struct ServiceLinkSession: Codable {
    
    let userId: Int
    let memberId: Int
    let memberName: String

    let clientId: Int
    let clientName: String

    let roleId: Int

    let token: String
    let allowPublicTaskRequests: Bool
    
    let elderFlag: Bool
    let useElderTools: Bool
    
    let useDirectory: Bool
    let directoryId: Int?
    
    var isAdmin: Bool {
        roleId < 3
    }
}
