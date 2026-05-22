//
//  ServiceLinkApp.swift
//  ServiceLink
//
//  Created by Michael Anderson on 5/22/26.
//

import SwiftUI

@main
struct ServiceLinkApp: App {

    @StateObject private var appState = AppState()

    var body: some Scene {

        WindowGroup {

            if appState.session == nil {

                LoginView()
                    .environmentObject(appState)

            } else {

                UpcomingAssignmentsView()
                    .environmentObject(appState)

            }
        }
    }
}
