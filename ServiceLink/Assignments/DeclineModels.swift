//
//  DeclineModels.swift
//  ServiceLink
//
//  Created by Michael Anderson on 5/22/26.
//

import Foundation

struct DeclineAssignmentRequest: Codable {

    let id: Int
    let clientId: Int
    let memberId: Int
}
