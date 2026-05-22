//
//  LoginView.swift
//  ServiceLink
//
//  Created by Michael Anderson on 5/22/26.
//

import SwiftUI

struct LoginView: View {

    @EnvironmentObject var appState: AppState
    @StateObject private var vm = LoginViewModel()

    var body: some View {
        VStack(spacing: 20) {

            Spacer()

            Image(systemName: "link.circle.fill")
                .font(.system(size: 84))
                .foregroundStyle(.blue)

            Text("ServiceLink")
                .font(.largeTitle)
                .fontWeight(.semibold)

            Text("Sign in to view your assignments")
                .foregroundStyle(.secondary)

            TextField("Email", text: $vm.email)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)

            SecureField("Password", text: $vm.password)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)

            if let error = vm.errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.caption)
            }

            Button {
                Task {
                    await vm.login(appState: appState)
                }
            } label: {
                if vm.isLoading {
                    ProgressView()
                } else {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(vm.isLoading)

            Spacer()
        }
        .padding()
    }
}
