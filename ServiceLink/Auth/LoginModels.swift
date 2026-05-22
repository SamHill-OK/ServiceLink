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
    let memberId: Int
    let memberName: String
    let clientId: Int
    let clientName: String
    let roleId: Int
    let token: String
}
