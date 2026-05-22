//
//  UpcomingAssignmentsView.swift
//  ServiceLink
//
//  Created by Michael Anderson on 5/22/26.
//

import SwiftUI

struct UpcomingAssignmentsView: View {

    @EnvironmentObject var appState: AppState

    @StateObject private var vm =
        UpcomingAssignmentsViewModel()

    var body: some View {

        NavigationStack {

            Group {

                if vm.isLoading {

                    ProgressView()

                } else if let error =
                            vm.errorMessage {

                    Text(error)

                } else if vm.assignments.isEmpty {

                    ContentUnavailableView(
                        "No Assignments",
                        systemImage:
                            "calendar.badge.exclamationmark"
                    )

                } else {

                    List(vm.assignments) { item in

                        VStack(
                            alignment: .leading,
                            spacing: 6
                        ) {

                            Text(item.worshipName)
                                .font(.headline)

                            Text(
                                item.daySession
                            )
                            .foregroundStyle(
                                .secondary
                            )

                            Text(item.formattedCalendarDate)
                                .font(.caption)
                        }
                    }
                }
            }
            .navigationTitle(
                "Upcoming Assignments"
            )
            .task {
                await vm.load(
                    appState: appState
                )
            }
        }
    }
}
