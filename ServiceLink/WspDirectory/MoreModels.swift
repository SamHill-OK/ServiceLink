//
//  MoreModels.swift
//  ServiceLink
//
//  Created by Michael Anderson on 8/29/26.
//

import Foundation

struct DirectoryBirthday: Codable, Identifiable {

    let memberId: Int
    let familyId: Int
    let displayName: String
    let birthday: String
    let phoneNumber: String?
    let familyThumbnailUrl: String?

    var id: Int {
        memberId
    }
}

struct DirectoryAnniversary: Codable, Identifiable {

    let familyId: Int

    let displayName: String

    let anniversaryDate: String

    let phone1Name: String?

    let phone1: String?

    let phone2Name: String?

    let phone2: String?

    let familyThumbnailUrl: String?

    var id: Int {
        familyId
    }

}
