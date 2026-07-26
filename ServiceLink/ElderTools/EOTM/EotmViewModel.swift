//
//  EotmViewModel.swift
//  ServiceLink
//
//  Created by Michael Anderson on 6/10/26.
//

import Foundation
import Combine

@MainActor
final class EotmViewModel: ObservableObject {

    @Published var session: ServiceLinkSession?
    @Published var eotmList: [EotmDto] = []
    @Published var eotmElders: [EotmElderOptionDto] = []
    @Published var isLoading = false

    func configure(session: ServiceLinkSession) {
        self.session = session
    }

    func load() async {
        await loadEotmList()
        await loadEotmElders()
    }

    func loadEotmList() async {
        guard let session else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            let items =
                try await ApiClient.shared.getEotmList(
                    clientId: session.clientId
                )

            let now = Date()

            let components =
                Calendar.current.dateComponents(
                    [.year, .month],
                    from: now
                )

            eotmList = items.filter { item in
                guard let year = components.year,
                      let month = components.month,
                      let itemMonth = item.calMonth
                else {
                    return false
                }

                return item.calYear > year ||
                    (
                        item.calYear == year &&
                        itemMonth >= month
                    )
            }

        } catch {
            print(
                "❌ loadEotmList error:",
                error.localizedDescription
            )

            eotmList = []
        }
    }

    func loadEotmElders() async {
        guard let session else { return }

        do {
            eotmElders = try await ApiClient.shared.getEotmElders(clientId: session.clientId)
        } catch {
            print("❌ loadEotmElders failed:", error.localizedDescription)
            eotmElders = []
        }
    }

    func replaceEotm(eotmId: Int, newElderId: Int) async {
        guard let session else { return }

        do {
            try await ApiClient.shared.replaceEotm(
                clientId: session.clientId,
                eotmId: eotmId,
                newElderId: newElderId
            )

            await loadEotmList()

        } catch {
            print("❌ replaceEotm failed:", error.localizedDescription)
        }
    }

    func swapEotm(firstId: Int, secondId: Int) async {
        guard let session else { return }

        do {
            try await ApiClient.shared.swapEotm(
                clientId: session.clientId,
                firstEotmId: firstId,
                secondEotmId: secondId
            )

            await loadEotmList()

        } catch {
            print("❌ swapEotm failed:", error.localizedDescription)
        }
    }
}
