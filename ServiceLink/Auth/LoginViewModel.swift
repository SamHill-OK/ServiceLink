import Foundation
import Combine

@MainActor
final class LoginViewModel: ObservableObject {

    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage: String?
    @Published var isLoading = false

    func login(appState: AppState) async {
        errorMessage = nil
        isLoading = true

        defer { isLoading = false }

        do {
            let response = try await ApiClient.shared.login(
                email: email,
                password: password
            )

            let congregations =
                response.congregations ?? []

            print(
                "Congregation count =",
                congregations.count
            )

            if congregations.count > 1 {

                // Do not create the session yet.
                // The user must select a congregation.
                appState.availableCongregations =
                    congregations

                appState.pendingLoginResponse =
                    response

                return
            }

            let selectedCongregation =
                congregations.first
                ?? LoginCongregation(
                    memberID: response.memberID,
                    memberName: response.memberName,
                    clientID: response.clientID,
                    clientName: response.clientName,
                    roleID: response.roleID,
                    allowPublicTaskRequests:
                        response.allowPublicTaskRequests ?? false,
                    elderFlag:
                        response.elderFlag,
                    useElderTools:
                        response.useElderTools
                )

            appState.completeLogin(
                response: response,
                congregation: selectedCongregation
            )

        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
}
