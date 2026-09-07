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

    let userID: Int
    let memberID: Int
    let memberName: String

    let clientID: Int
    let clientName: String

    let roleID: Int

    let token: String
    let allowPublicTaskRequests: Bool?
    
    let elderFlag: Bool
    let useElderTools: Bool
    let useDirectory: Bool?
    let directoryID: Int?
    
    let globalUserID: Int?
    let congregations: [LoginCongregation]?

}


struct LoginCongregation: Codable, Identifiable {

    let userID: Int
    let memberID: Int
    let memberName: String

    let clientID: Int
    let clientName: String

    let roleID: Int

    let allowPublicTaskRequests: Bool?
    let elderFlag: Bool
    let useElderTools: Bool
    
    let useDirectory: Bool?
    let directoryID: Int?

    var id: Int {
        clientID
    }
}

struct LeaveCongregationRequest: Codable {

    let globalUserId: Int
    let userId: Int
    let clientId: Int
}
