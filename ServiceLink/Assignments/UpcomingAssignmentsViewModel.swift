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
                try await ApiClient.shared.getAssignments(
                    clientId: session.clientId,
                    memberId: session.memberId
                )
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
