//
//  TaskChoiceModels.swift
//  ServiceLink
//
//  Created by Michael Anderson on 5/23/26.
//

import Foundation

struct ServiceLinkTaskChoiceMember: Codable, Identifiable, Hashable {
    let memberId: Int
    let memberName: String

    var id: Int { memberId }
}

struct ServiceLinkTaskChoice: Codable, Identifiable {
    let clientId: Int
    let memberId: Int
    let worshipId: Int
    let worshipName: String
    let worshipDay: String
    let worshipSession: String
    var onFlag: Bool

    var id: Int { worshipId }
}

struct ServiceLinkTaskChoiceRequest: Codable {
    let clientId: Int
    let memberId: Int
    let worshipId: Int
    let onFlag: Bool
}
