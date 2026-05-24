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

        let groups = vm.groupedChoices

        return List {

            ForEach(
                Array(groups.enumerated()),
                id: \.element.id
            ) { _, group in

                HStack {

                    VStack(
                        alignment: .leading,
                        spacing: 4
                    ) {

                        Text(group.worshipName)
                            .font(.headline)

                        Text("\(group.worshipDay) • \(group.worshipSession)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    if appState.session?.allowPublicTaskRequests ?? false {

                        Button {

                            Task {
                                await vm.requestChoiceGroup(
                                    group: group,
                                    appState: appState
                                )
                            }

                        } label: {

                            choiceIcon(group)
                        }
                        .buttonStyle(.plain)

                    } else {

                        choiceIcon(group)
                    }
                }
            }
        }
    }

    private func choiceIcon(
        _ group: ServiceLinkTaskChoiceGroup
    ) -> some View {

        Image(
            systemName:
                group.isOn
            ? "checkmark.circle.fill"
            : "circle"
        )
        .foregroundStyle(
            group.isOn
            ? .green
            : .gray
        )
    }
}
