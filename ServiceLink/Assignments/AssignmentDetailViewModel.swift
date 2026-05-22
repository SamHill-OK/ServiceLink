//
//  AssignmentDetailViewModel.swift
//  ServiceLink
//
//  Created by Michael Anderson on 5/22/26.
//

import Foundation
import Combine

@MainActor
final class AssignmentDetailViewModel: ObservableObject {

    @Published var isSubmitting = false
    @Published var errorMessage: String?

    func decline(
        assignment: ServiceLinkAssignment
    ) async -> Bool {

        errorMessage = nil
        isSubmitting = true

        defer {
            isSubmitting = false
        }

        do {
            try await ApiClient.shared.declineAssignment(
                id: assignment.id,
                clientId: assignment.clientId,
                memberId: assignment.memberId
            )

            return true

        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
