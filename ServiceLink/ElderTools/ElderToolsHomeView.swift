//
//  ElderToolsHomeView.swift
//  ServiceLink
//
//  Created by Michael Anderson on 5/28/26.
//

import SwiftUI

struct ElderToolsHomeView: View {

    @ObservedObject var vm: ElderToolsViewModel

    var body: some View {
        VStack(spacing: 20) {

            NavigationLink {
                ReachOutView(vm: vm)
            } label: {
                ElderTile(
                    title: "Connection Tool",
                    subtitle: "Reach out to households",
                    systemImage: "phone.fill"
                )
            }

            NavigationLink {
                AddGoForwardView(vm: vm)
            } label: {
                ElderTile(
                    title: "Go Forward Follow-Up",
                    subtitle: "Track prayer & repentance requests",
                    systemImage: "person.crop.circle.badge.plus"
                )
            }
            
            NavigationLink {
                EotmView(vm: vm)
            } label: {
                ElderTile(
                    title: "Elder of the Month",
                    subtitle: "See rotation schedule",
                    systemImage: "calendar"
                )
            }


            Spacer()
        }
        .padding()
        .navigationTitle("Elder Tools")
    }
}
