//
//  DirectoryStaffViewModel.swift
//  ServiceLink
//
//  Created by Michael Anderson on 8/29/26.
//

import Foundation
import Combine

@MainActor
final class DirectoryStaffViewModel: ObservableObject {

    @Published var staff: [DirectoryStaffMember] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func load(
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

            staff =
                try await ApiClient.shared.getDirectoryStaff(
                    clientId: session.clientId,
                    activeOnly: true
                )

        } catch let error as URLError
            where error.code == .cancelled {

            return

        } catch is CancellationError {

            return

        } catch {

            errorMessage = error.localizedDescription
        }
    }
}
