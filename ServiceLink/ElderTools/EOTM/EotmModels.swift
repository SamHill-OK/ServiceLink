//
//  EotmModels.swift
//  ServiceLink
//
//  Created by Michael Anderson on 6/10/26.
//

import Foundation

struct EotmDto: Codable, Identifiable {

    let id: Int
    let calYear: Int
    let calMonth: Int?
    let elderName: String?

    var monthName: String {
        guard let month = calMonth else { return "" }
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
