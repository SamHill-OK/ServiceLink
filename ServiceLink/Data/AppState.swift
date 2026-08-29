//
//  AppState.swift
//  ServiceLink
//
//  Created by Michael Anderson on 5/22/26.
//

import Foundation
import Combine

@MainActor
final class AppState: ObservableObject {

    @Published var session: ServiceLinkSession? {
        didSet {
            if let session {
                SessionStore.shared.save(session: session)
            } else {
                SessionStore.shared.clear()
            }
        }
    }

    @Published var availableCongregations:
        [LoginCongregation] = []

    @Published var pendingLoginResponse:
        LoginResponse?

    var needsCongregationSelection: Bool {
        pendingLoginResponse != nil &&
        availableCongregations.count > 1
    }

    init() {
        self.session = SessionStore.shared.load()

        if session != nil {
            CrashTrail.log("Session restored")
        } else {
            CrashTrail.log("No saved session")
        }
    }

    func completeLogin(
        response: LoginResponse,
        congregation: LoginCongregation
    ) {
        session =
            ServiceLinkSession(
                memberId: congregation.memberID,
                memberName: congregation.memberName,
                clientId: congregation.clientID,
                clientName: congregation.clientName,
                roleId: congregation.roleID,
                token: response.token,
                allowPublicTaskRequests:
                    congregation.allowPublicTaskRequests ?? false,
                elderFlag:
                    congregation.elderFlag,
                useElderTools:
                    congregation.useElderTools
            )

        availableCongregations = []
        pendingLoginResponse = nil
    }

    func cancelCongregationSelection() {
        availableCongregations = []
        pendingLoginResponse = nil
    }

    func logout() {
        availableCongregations = []
        pendingLoginResponse = nil
        session = nil
    }
}
