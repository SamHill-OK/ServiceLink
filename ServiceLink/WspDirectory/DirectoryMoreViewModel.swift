//
//  DirectoryMoreViewModel.swift
//  ServiceLink
//
//  Created by Michael Anderson on 8/29/26.
//

import Foundation
import Combine

@MainActor
final class DirectoryMoreViewModel: ObservableObject {

    @Published var activities: [DirectoryActivity] = []

    @Published var isLoading = false

    @Published var errorMessage: String?
    @Published var birthdays: [DirectoryBirthday] = []

    @Published var anniversaries: [DirectoryAnniversary] = []

    func loadActivities(
        appState: AppState,
        year: Int,
        month: Int
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
            let calendar = Calendar.current
            let today =
                calendar.startOfDay(
                    for: Date()
                )

            let dateFormatter =
                DateFormatter()

            dateFormatter.calendar =
                calendar

            dateFormatter.locale =
                Locale(
                    identifier: "en_US_POSIX"
                )

            dateFormatter.dateFormat =
                "yyyy-MM-dd"

            activities =
                try await ApiClient.shared.getActivities(
                    clientId: session.clientId,
                    year: year,
                    month: month
                )
                .filter { activity in
                    guard activity.activeFlag
                    else {
                        return false
                    }

                    guard let activityDate =
                        dateFormatter.date(
                            from: activity.activityDate
                        )
                    else {
                        return false
                    }

                    return calendar.startOfDay(
                        for: activityDate
                    ) >= today
                }

        } catch let error as URLError
            where error.code == .cancelled {

            return

        } catch is CancellationError {

            return

        } catch {

            errorMessage =
                error.localizedDescription
        }
    }
    func loadBirthdays(
        appState: AppState,
        year: Int,
        month: Int
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
            birthdays =
                try await ApiClient.shared.getBirthdays(
                    clientId: session.clientId,
                    year: year,
                    month: month
                )
        } catch let error as URLError
            where error.code == .cancelled {

            return

        } catch is CancellationError {

            return

        } catch {

            errorMessage =
                error.localizedDescription
        }
    }
    func loadAnniversaries(
        appState: AppState,
        year: Int,
        month: Int
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
            anniversaries =
                try await ApiClient.shared.getAnniversaries(
                    clientId: session.clientId,
                    year: year,
                    month: month
                )
        } catch let error as URLError
            where error.code == .cancelled {

            return

        } catch is CancellationError {

            return

        } catch {

            errorMessage =
                error.localizedDescription
        }
    }
}
