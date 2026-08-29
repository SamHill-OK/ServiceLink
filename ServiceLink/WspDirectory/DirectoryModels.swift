//
//  DirectoryModels.swift
//  ServiceLink
//
//  Created by Michael Anderson on 8/16/26.
//

import Foundation

struct DirectoryFamily: Identifiable, Codable {

    let wspFamilyId: Int

    let lastName: String
    let familyName: String?

    let addr1: String?
    let addr2: String?
    let adCity: String?
    let adState: String?
    let adZip: String?

    let familyPhotoBlobName: String?
    let familyPhotoUrl: String?
    let familyPhotoThumbnailUrl: String?

    let activeFlag: Bool
    let memberCount: Int
    let memberFirstNames: String

    var id: Int {
        wspFamilyId
    }

    var displayName: String {
        if let familyName,
           !familyName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return familyName
        }

        return "\(lastName) Family"
    }
}

struct DirectoryFamilyDetail: Identifiable, Codable {

    let wspFamilyId: Int

    let lastName: String
    let familyName: String?

    let addr1: String?
    let addr2: String?
    let adCity: String?
    let adState: String?
    let adZip: String?

    let familyPhotoBlobName: String?
    let familyPhotoUrl: String?
    let familyPhotoThumbnailUrl: String?

    let activeFlag: Bool

    let createdDateUtc: Date?
    let modifiedDateUtc: Date?

    let adults: [DirectoryFamilyMember]
    let children: [DirectoryFamilyMember]
    let unclassifiedMembers: [DirectoryFamilyMember]

    let anniversaryMonth: Int?
    let anniversaryDay: Int?
    let anniversaryYear: Int?

    var id: Int {
        wspFamilyId
    }

    var displayName: String {
        if let familyName,
           !familyName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return familyName
        }

        return "\(lastName) Family"
    }
}

struct DirectoryFamilyMember: Identifiable, Codable {

    let memberId: Int

    let firstName: String
    let lastName: String

    let phoneNumber: String?
    let smsNumber: String?
    let smsUser: Bool?

    let email: String?
    let birthday: Date?

    let mf: String?
    let activeFlag: Bool?

    let familyCode: Int?
    let familyRole: String?

    let serviceLinkParentMemberId: Int?
    let serviceLinkParentName: String?

    let linkedChildCount: Int
    let linkedChildNames: [String]

    var id: Int {
        memberId
    }

    var fullName: String {
        "\(firstName) \(lastName)"
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct DirectoryStaffMember: Identifiable, Codable {

    let directoryStaffId: Int

    let clientId: Int
    let memberId: Int

    let memberName: String
    let staffTitle: String

    let systemRoleCode: String?

    let staffPhotoUrl: String?
    let staffPhotoThumbnailUrl: String?

    let sortOrder: Int
    let activeFlag: Bool

    var id: Int {
        directoryStaffId
    }
}
