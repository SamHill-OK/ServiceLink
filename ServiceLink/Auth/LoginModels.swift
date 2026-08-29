//
//  LoginModels.swift
//  ServiceLink
//
//  Created by Michael Anderson on 5/22/26.
//

import Foundation

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct LoginResponse: Codable {

    let memberID: Int
    let memberName: String

    let clientID: Int
    let clientName: String

    let roleID: Int

    let token: String
    let allowPublicTaskRequests: Bool?
    
    let elderFlag: Bool
    let useElderTools: Bool
    let globalUserID: Int?
    let congregations: [LoginCongregation]?

}


struct LoginCongregation: Codable, Identifiable {

    let memberID: Int
    let memberName: String

    let clientID: Int
    let clientName: String

    let roleID: Int

    let allowPublicTaskRequests: Bool?
    let elderFlag: Bool
    let useElderTools: Bool

    var id: Int {
        clientID
    }
}
