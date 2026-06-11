//
//  ElderToolsHomeView.swift
//  ServiceLink
//
//  Created by Michael Anderson on 5/28/26.
//

import SwiftUI

struct ElderToolsHomeView: View {

    
    @EnvironmentObject var appState: AppState
    @StateObject private var eotmVm = EotmViewModel()

    var body: some View {
        VStack(spacing: 20) {

            NavigationLink {
                ReachOutView()
            } label: {
                ElderTile(
                    title: "Connection Tool",
                    subtitle: "Reach out to households",
                    systemImage: "phone.fill"
                )
            }
            /*
            NavigationLink {
                AddGoForwardView(vm: vm)
            } label: {
                ElderTile(
                    title: "Go Forward Follow-Up",
                    subtitle: "Track prayer & repentance requests",
                    systemImage: "person.crop.circle.badge.plus"
                )
            }
  */
  
            NavigationLink {
                EotmView(vm: eotmVm)
                    .onAppear {
                        if let session = appState.session {
                            eotmVm.configure(session: session)
                        }
                    }
            } label: {
                ElderTile(
                    title: "Elder of the Month",
                    subtitle: "See rotation schedule",
                    systemImage: "calendar"
                )
            }
    
           /* NavigationLink {
                ElderMeetingListView(vm: vm)
            } label: {
                ElderTile(
                    title: "Meeting Schedule",
                    subtitle: "Upcoming elder meetings",
                    systemImage: "person.3.sequence.fill"
                )
            }
        */
            Spacer()
        }
        .padding()
        .navigationTitle("Elder Tools")
    }
}
