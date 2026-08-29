//
//  DirectoryViewModel.swift
//  ServiceLink
//
//  Created by Michael Anderson on 8/16/26.
//

import Foundation
import Combine

@MainActor
final class DirectoryViewModel: ObservableObject {

    @Published var families: [DirectoryFamily] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadFamilies(
        appState: AppState,
        searchText: String? = nil
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

            families =
                try await ApiClient.shared.searchDirectoryFamilies(
                    clientId: session.clientId,
                    searchText: searchText,
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
