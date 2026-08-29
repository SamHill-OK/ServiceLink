//
//  DirectoryView.swift
//  ServiceLink
//
//  Created by Michael Anderson on 8/16/26.
//

import SwiftUI

struct DirectoryView: View {

    @EnvironmentObject var appState: AppState

    @State private var selectedTab: DirectoryTab = .families

    var body: some View {

        Group {

            switch selectedTab {

            case .families:
                DirectoryFamiliesView()

            case .staff:
                DirectoryStaffView()

            case .more:
                DirectoryMoreView()
            }
        }
        .navigationTitle("Directory")
        .safeAreaInset(edge: .bottom) {

            HStack {

                Button {
                    selectedTab = .families
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "house.fill")
                        Text("Families")
                            .font(.caption2)
                    }
                }

                Spacer()

                Button {
                    selectedTab = .staff
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "person.crop.rectangle.stack")
                        Text("Staff")
                            .font(.caption2)
                    }
                }

                Spacer()

                Button {
                    selectedTab = .more
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "ellipsis.circle")
                        Text("More")
                            .font(.caption2)
                    }
                }
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
        }
    }
}

enum DirectoryTab {
    case families
    case staff
    case more
}
