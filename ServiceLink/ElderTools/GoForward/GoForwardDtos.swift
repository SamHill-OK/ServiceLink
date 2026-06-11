//
//  GoForwardDtos.swift
//  ServiceLink
//
//  Created by Michael Anderson on 6/11/26.
//

// GoForwardRecentDto.swift

import Foundation

struct GoForwardRecentDto: Codable, Identifiable {

    let goForwardId: Int
    let memberId: Int

    let firstName: String
    let lastName: String

    let phoneNumber: String?
    let note: String

    let goForwardDate: String

    var id: Int { goForwardId }
}
import Foundation

struct MemberLookupDto: Codable, Identifiable {

    let memberID: Int
    let firstName: String
    let lastName: String
    let phoneNumber: String?

    var id: Int { memberID }
}
