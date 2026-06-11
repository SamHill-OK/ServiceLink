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
    init() {
        
        CrashTrail.log("App launched")
                print("🧨 Last CrashTrail: \(CrashTrail.lastMessage)")
    }
    var body: some Scene {

        WindowGroup {

            if appState.session == nil {

                LoginView()
                    .environmentObject(appState)

            } else {

                UpcomingAssignmentsView()
                    .environmentObject(appState)
                    .onAppear {
                        CrashTrail.log("UpcomingAssignments appeared")
                    }

            }
        }
    }
}
