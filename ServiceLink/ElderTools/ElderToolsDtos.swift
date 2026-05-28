//
//  ElderToolsDtos.swift
//  ServiceLink
//
//  Created by Michael Anderson on 5/28/26.
//

import Foundation

struct ElderNextResult: Codable {
    let memberID: Int
    let firstName: String
    let lastName: String
    let phoneNumber: String?
}

struct GoForwardRecentDto: Codable, Identifiable {
    let goForwardId: Int
    let memberId: Int
    let firstName: String
    let lastName: String
    let phoneNumber: String?
    let note: String
    let goForwardDate: Date

    var id: Int { goForwardId }
}
struct MemberLookupDto: Codable, Identifiable {

    let memberID: Int
    let firstName: String
    let lastName: String
    let phoneNumber: String?

    var id: Int { memberID }
}


struct EotmDto: Codable, Identifiable {

    let id: Int
    let calYear: Int
    let calMonth: Int?
    let elderName: String?

    var monthName: String {
        guard let month = calMonth,
              let date = Calendar.current.date(from: DateComponents(year: 2024, month: month))
        else { return "" }

        return DateFormatter().monthSymbols[month - 1]
    }
}

struct EotmElderOptionDto: Codable, Identifiable, Hashable {
    let memberId: Int
    let elderName: String

    var id: Int { memberId }
}

struct SwapEotmRequest: Codable {
    let clientId: Int
    let firstEotmId: Int
    let secondEotmId: Int
}
struct UpdateEotmRequest: Codable {
    let id: Int
    let clientId: Int
    let elderId: Int
}


