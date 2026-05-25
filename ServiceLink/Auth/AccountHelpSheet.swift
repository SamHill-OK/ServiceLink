//
//  AccountHelpSheet.swift
//  ServiceLink
//
//  Created by Michael Anderson on 5/25/26.
//

import SwiftUI

enum AccountHelpMode {
    case forgotPassword
    case setupAccount

    var title: String {
        switch self {
        case .forgotPassword:
            return "Forgot Password"
        case .setupAccount:
            return "Set Up Account"
        }
    }

    var message: String {
        switch self {
        case .forgotPassword:
            return "Enter your email and we will send password reset instructions."
        case .setupAccount:
            return "Enter your email and we will send setup instructions if your email is active in your church records."
        }
    }
}

struct AccountHelpSheet: View {

    let mode: AccountHelpMode
    
    

    @Environment(\.dismiss) private var dismiss

    @State private var email = ""
    @State private var isLoading = false
    @State private var message: String?
    @State private var errorMessage: String?

    var body: some View {

        NavigationStack {

            VStack(spacing: 16) {

                Text(mode.message)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top)

                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)

                if let message {
                    Text(message)
                        .font(.caption)
                        .foregroundStyle(.green)
                        .multilineTextAlignment(.center)
                }

                if let errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }

                Button {

                    //print("SEND BUTTON TAPPED")

                    Task {
                        await submit()
                    }

                } label: {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text("Send Instructions")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isLoading || email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                Spacer()
            }
            .padding()
            .navigationTitle(mode.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func submit() async {

        //print("AccountHelp mode =", mode)
        //print("Email =", email)

        isLoading = true
        message = nil
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {

            switch mode {

            case .forgotPassword:

                //print("Calling ForgotPassword")

                try await ApiClient.shared
                    .forgotPassword(
                        email: email
                    )

            case .setupAccount:

               // print(
              //      "Calling RequestServiceLinkAccount"
              //  )

                try await ApiClient.shared
                    .requestServiceLinkAccount(
                        email: email
                    )
            }

            //print("SUCCESS")

            message =
            """
            If your email is active in your church records,
            instructions have been sent.
            """

        } catch {

            print(
                "ERROR =",
                error.localizedDescription
            )

            errorMessage =
                error.localizedDescription
        }
    }
}
