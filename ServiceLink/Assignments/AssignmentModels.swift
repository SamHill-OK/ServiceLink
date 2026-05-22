//
//  AssignmentModels.swift
//  ServiceLink
//
//  Created by Michael Anderson on 5/22/26.
//

import Foundation

struct ServiceLinkAssignment: Codable, Identifiable {

    let id: Int

    let clientId: Int
    let memberId: Int

    let worshipDate: String

    let worshipDay: String
    let worshipSession: String
    let worshipName: String

    let daySession: String
    let memberName: String

    let smsReply: String

    let taskClass: Int?
    let sortOrder: Int?
    let sessionOrder: Int
}
