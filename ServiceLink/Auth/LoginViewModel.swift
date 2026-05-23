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

            appState.session =
                ServiceLinkSession(
                    memberId: response.memberID,
                    memberName: response.memberName,
                    clientId: response.clientID,
                    clientName: response.clientName,
                    roleId: response.roleID,
                    token: response.token,
                    allowPublicTaskRequests:
                        response.allowPublicTaskRequests ?? false
                )

        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
