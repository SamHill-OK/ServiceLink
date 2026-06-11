//
//  UpcomingAssignmentsViewModel.swift
//  ServiceLink
//
//  Created by Michael Anderson on 5/22/26.
//

import Foundation
import Combine

@MainActor
final class UpcomingAssignmentsViewModel: ObservableObject {

    @Published var assignments: [ServiceLinkAssignment] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func load(appState: AppState) async {

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
            assignments =
                try await ApiClient.shared.getAssignmentsForMember(
                    clientId: session.clientId,
                    memberId: session.memberId
                )

        } catch let error as URLError where error.code == .cancelled {
            return

        } catch is CancellationError {
            return

        } catch {
            errorMessage = error.localizedDescription
        }
    }
    func respond(
        assignment: ServiceLinkAssignment,
        reply: String,
        appState: AppState
    ) async {

        errorMessage = nil

        do {
            try await ApiClient.shared.respondAssignment(
                id: assignment.id,
                clientId: assignment.clientId,
                memberId: assignment.memberId,
                reply: reply
            )

            await load(appState: appState)

        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
