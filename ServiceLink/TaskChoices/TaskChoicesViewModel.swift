//
//  TaskChoicesViewModel.swift
//  ServiceLink
//
//  Created by Michael Anderson on 5/23/26.
//

import Foundation
import Combine

@MainActor
final class TaskChoicesViewModel: ObservableObject {

    @Published var members: [ServiceLinkTaskChoiceMember] = []
    @Published var selectedMember: ServiceLinkTaskChoiceMember?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var choices: [ServiceLinkTaskChoice] = []
    var groupedChoices: [ServiceLinkTaskChoiceGroup] {

        Dictionary(grouping: choices) {
            "\($0.worshipDay)|\($0.worshipSession)|\($0.worshipName)"
        }
        .map { _, tasks in
            let first = tasks.first!

            return ServiceLinkTaskChoiceGroup(
                worshipName: first.worshipName,
                worshipDay: first.worshipDay,
                worshipSession: first.worshipSession,
                tasks: tasks
            )
        }
        .sorted {
            if $0.worshipDay != $1.worshipDay {
                return $0.worshipDay < $1.worshipDay
            }

            if $0.worshipSession != $1.worshipSession {
                return $0.worshipSession < $1.worshipSession
            }

            return $0.worshipName < $1.worshipName
        }
    }

    func loadMembers(appState: AppState) async {

        guard let session = appState.session else {
            errorMessage = "No active session."
            return
        }

        errorMessage = nil
        isLoading = true

        defer {
            isLoading = false
        }

        do {
            members =
                try await ApiClient.shared.getTaskChoiceMembers(
                    clientId: session.clientId,
                    memberId: session.memberId
                )

            if let firstMember = members.first {

                selectedMember = firstMember

                await loadChoices(
                    memberId: firstMember.memberId,
                    appState: appState
                )

            } else {

                selectedMember = nil
                choices = []
            }

        } catch {
            errorMessage = error.localizedDescription
        }
    }
    func selectMember(
        _ member: ServiceLinkTaskChoiceMember,
        appState: AppState
    ) async {

        selectedMember = member
        await loadChoices(
            memberId: member.memberId,
            appState: appState
        )
    }

    func loadChoices(
        memberId: Int,
        appState: AppState
    ) async {

        guard let session = appState.session else {
            errorMessage = "No active session."
            return
        }

        errorMessage = nil
        isLoading = true

        defer {
            isLoading = false
        }

        do {
            choices =
                try await ApiClient.shared.getTaskChoices(
                    clientId: session.clientId,
                    memberId: memberId
                )
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func requestChoice(
        choice: ServiceLinkTaskChoice,
        appState: AppState
    ) async {

        guard let session = appState.session,
              let selectedMember = selectedMember
        else {
            errorMessage = "No active session."
            return
        }

        let newValue = !choice.onFlag

        if let index = choices.firstIndex(where: { $0.worshipId == choice.worshipId }) {
            choices[index].onFlag = newValue
        }

        do {
            try await ApiClient.shared.requestTaskChoice(
                clientId: session.clientId,
                memberId: selectedMember.memberId,
                worshipId: choice.worshipId,
                onFlag: newValue
            )
        } catch {
            if let index = choices.firstIndex(where: { $0.worshipId == choice.worshipId }) {
                choices[index].onFlag.toggle()
            }

            errorMessage = error.localizedDescription
        }
    }
    func requestChoiceGroup(
        group: ServiceLinkTaskChoiceGroup,
        appState: AppState
    ) async {

        guard let session = appState.session,
              let selectedMember = selectedMember
        else {
            errorMessage = "No active session."
            return
        }

        let newValue = !group.isOn

        for task in group.tasks {

            if let index = choices.firstIndex(where: { $0.worshipId == task.worshipId }) {
                choices[index].onFlag = newValue
            }

            do {
                try await ApiClient.shared.requestTaskChoice(
                    clientId: session.clientId,
                    memberId: selectedMember.memberId,
                    worshipId: task.worshipId,
                    onFlag: newValue
                )
            } catch {
                if let index = choices.firstIndex(where: { $0.worshipId == task.worshipId }) {
                    choices[index].onFlag.toggle()
                }

                errorMessage = error.localizedDescription
            }
        }
    }
    
}
