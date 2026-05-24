//
//  UpcomingAssignmentsView.swift
//  ServiceLink
//
//  Created by Michael Anderson on 5/22/26.
//

import SwiftUI

struct UpcomingAssignmentsView: View {

    @EnvironmentObject var appState: AppState
    @Environment(\.scenePhase) private var scenePhase
    @State private var selectedAssignment:
        ServiceLinkAssignment?

    @State private var pendingReply: String?

    @State private var showReplyConfirm = false

    @StateObject private var vm =
        UpcomingAssignmentsViewModel()
    private var groupedAssignments: [(memberName: String, items: [ServiceLinkAssignment])] {
        Dictionary(grouping: vm.assignments) { item in
            item.memberName
        }
        .map { memberName, items in
            (
                memberName: memberName,
                items: items.sorted {
                    if $0.worshipDate != $1.worshipDate {
                        return $0.worshipDate < $1.worshipDate
                    }

                    if $0.sessionOrder != $1.sessionOrder {
                        return $0.sessionOrder < $1.sessionOrder
                    }

                    return ($0.sortOrder ?? 0) < ($1.sortOrder ?? 0)
                }
            )
        }
        .sorted { $0.memberName < $1.memberName }
    }

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
                    
                    List {
                        ForEach(groupedAssignments, id: \.memberName) { group in

                            Section {
                                ForEach(group.items) { item in

                                    NavigationLink {
                                        AssignmentDetailView(assignment: item)
                                    } label: {
                                        VStack(
                                            alignment: .leading,
                                            spacing: 6
                                        ) {

                                            Text(item.worshipName)
                                                .font(.headline)

                                            Text(item.daySession)
                                                .foregroundStyle(.secondary)

                                            Text(item.formattedCalendarDate)
                                                .font(.caption)

                                            Text(item.assignmentStatus)
                                                .font(.caption)
                                                .foregroundStyle(
                                                    item.assignmentStatus == "Confirmed"
                                                    ? .green
                                                    : item.assignmentStatus == "Declined"
                                                    ? .red
                                                    : .orange
                                                )
                                            if item.assignmentStatus == "Pending" {
                                                HStack {
                                                    Button {

                                                        selectedAssignment = item
                                                        pendingReply = "Y"
                                                        showReplyConfirm = true

                                                    } label: {
                                                        Label(
                                                            "Accept",
                                                            systemImage:
                                                                "checkmark.circle.fill"
                                                        )
                                                    }
                                                    .buttonStyle(.borderedProminent)
                                                    .tint(.green)

                                                    Button {

                                                        selectedAssignment = item
                                                        pendingReply = "N"
                                                        showReplyConfirm = true

                                                    } label: {
                                                        Label(
                                                            "Decline",
                                                            systemImage:
                                                                "xmark.circle.fill"
                                                        )
                                                    }
                                                    .buttonStyle(.borderedProminent)
                                                    .tint(.red)
                                                }
                                                .padding(.top, 4)
                                            }
                                        }
                                    }
                                }
                            } header: {
                                Text(group.memberName)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                            }
                        }
                    }
                }
            }
            /*.navigationTitle(appState.session?.clientName ?? "")*/
            .toolbar {

                ToolbarItem(
                    placement: .principal
                ) {

                    VStack(spacing: 2) {

                        Text("Upcoming Assignments")
                            .font(.headline)

                        Text(appState.session?.clientName ?? "")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text("Hello \(appState.session?.memberName ?? "")!")
                            .font(.caption)
                            .foregroundStyle(.blue)
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {

                HStack {

                    NavigationLink {

                        TaskChoicesView()

                    } label: {

                        VStack(spacing: 4) {

                            Image(systemName: "checklist")

                            Text("Tasks")
                                .font(.caption2)
                        }
                    }

                    Spacer()

                    Button {

                        appState.logout()

                    } label: {

                        VStack(spacing: 4) {

                            Image(systemName: "rectangle.portrait.and.arrow.right")

                            Text("Logout")
                                .font(.caption2)
                        }
                    }
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
            }
            .task {
                await vm.load(
                    appState: appState
                )
            }
            
            .onChange(of: scenePhase) {
                if scenePhase == .active {
                    Task {
                        await vm.load(appState: appState)
                    }
                }
            }
            .alert(
                pendingReply == "Y"
                ? "Confirm Assignment"
                : "Decline Assignment",
                isPresented: $showReplyConfirm
            ) {

                Button(
                    pendingReply == "Y"
                    ? "Accept"
                    : "Decline",
                    role:
                        pendingReply == "N"
                        ? .destructive
                        : nil
                ) {

                    guard let assignment =
                        selectedAssignment,
                          let reply =
                            pendingReply
                    else {
                        return
                    }

                    Task {

                        await vm.respond(
                            assignment:
                                assignment,
                            reply:
                                reply,
                            appState:
                                appState
                        )

                        selectedAssignment = nil
                        pendingReply = nil
                    }
                }

                Button(
                    "Cancel",
                    role: .cancel
                ) {
                    selectedAssignment = nil
                    pendingReply = nil
                }

            } message: {

                Text(
                    pendingReply == "Y"
                    ? "Confirm this assignment?"
                    : "WSP will try to reassign this task."
                )
            }
        }
    }
}
