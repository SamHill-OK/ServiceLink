//
//  DirectoryFamilyDetailViewModel.swift
//  ServiceLink
//
//  Created by Michael Anderson on 8/16/26.
//

import Foundation
import Combine

@MainActor
final class DirectoryFamilyDetailViewModel: ObservableObject {

    @Published var family: DirectoryFamilyDetail?
    @Published var isLoading = false
    @Published var errorMessage: String?

    func load(
        appState: AppState,
        wspFamilyId: Int
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

            family =
                try await ApiClient.shared.getDirectoryFamily(
                    clientId: session.clientId,
                    wspFamilyId: wspFamilyId
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
