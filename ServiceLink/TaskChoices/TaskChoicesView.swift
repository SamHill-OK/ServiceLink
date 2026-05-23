//
//  TaskChoicesView.swift
//  ServiceLink
//
//  Created by Michael Anderson on 5/23/26.
//

import SwiftUI

struct TaskChoicesView: View {

    @EnvironmentObject var appState: AppState
    @StateObject private var vm = TaskChoicesViewModel()

    var body: some View {

        VStack(spacing: 16) {

            if vm.isLoading {

                ProgressView()

            } else if let error = vm.errorMessage {

                Text(error)
                    .foregroundStyle(.red)

            } else {

                Text("Task Choices")
                    .font(.headline)

                memberPicker

                Text(
                    "Selected: \(vm.selectedMember?.memberName ?? "None")"
                )

                taskList
            }
        }
        .navigationTitle("Task Choices")
        .task {
            await vm.loadMembers(appState: appState)
        }
    }

    private var memberPicker: some View {

        Group {

            if vm.members.count > 1 {

                Picker(
                    "Member",
                    selection: $vm.selectedMember
                ) {

                    ForEach(vm.members) { member in

                        Text(member.memberName)
                            .tag(member as ServiceLinkTaskChoiceMember?)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .onChange(of: vm.selectedMember) { _, newValue in

                    if let newValue {

                        Task {
                            await vm.loadChoices(
                                memberId: newValue.memberId,
                                appState: appState
                            )
                        }
                    }
                }
            }
        }
    }

    private var taskList: some View {

        List {

            ForEach(vm.choices) { choice in

                HStack {

                    VStack(alignment: .leading, spacing: 4) {

                        Text(choice.worshipName)
                            .font(.headline)

                        Text("\(choice.worshipDay) • \(choice.worshipSession)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    if appState.session?.allowPublicTaskRequests ?? false {

                        Button {

                            Task {
                                await vm.requestChoice(
                                    choice: choice,
                                    appState: appState
                                )
                            }

                        } label: {

                            choiceIcon(choice)
                        }
                        .buttonStyle(.plain)

                    } else {

                        choiceIcon(choice)
                    }
                }
            }
        }
    }

    private func choiceIcon(
        _ choice: ServiceLinkTaskChoice
    ) -> some View {

        Image(
            systemName:
                choice.onFlag
            ? "checkmark.circle.fill"
            : "circle"
        )
        .foregroundStyle(
            choice.onFlag
            ? .green
            : .gray
        )
    }
}
