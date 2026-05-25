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
    @State private var showUpdateAlert = false

    @State private var updateRequired = false

    @State private var updateMessage = ""

    @State private var appStoreUrl = ""
    @State private var showForgotPasswordSheet = false
    @State private var showSetupAccountSheet = false
    
    
 
    
    var body: some View {
        VStack(spacing: 20) {
            
            Spacer()
            Image("ServiceLinkLogo")
                .resizable()
                .scaledToFit()
                .frame(height: 220)
                .padding(.horizontal)
                .padding(.horizontal)
                       
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
                //print("LOGIN BUTTON TAPPED")
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
            
            HStack(spacing: 24) {

                Button("Forgot Password?") {
                    showForgotPasswordSheet = true
                }
                .font(.caption)

                Button("Set Up Account") {
                    showSetupAccountSheet = true
                }
                .font(.caption)
            }
            
            VStack(spacing: 2) {
                
                Text("Powered by ")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Image("WspLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 60)
                    .offset(y: -8)
            }
            .padding(.bottom, 16)
        }
        .task {
            await checkForAppUpdate()
        }
        .sheet(isPresented: $showForgotPasswordSheet) {
            AccountHelpSheet(mode: .forgotPassword)
        }

        .sheet(isPresented: $showSetupAccountSheet) {
            AccountHelpSheet(mode: .setupAccount)
        }
        .alert(
            updateRequired
            ? "Update Required"
            : "Update Available",

            isPresented:
                $showUpdateAlert
        ) {

            Button("Update") {

                guard let url =
                    URL(
                        string:
                            appStoreUrl
                    )
                else {
                    return
                }

                UIApplication.shared
                    .open(url)
            }

            if !updateRequired {

                Button(
                    "Later",
                    role:.cancel
                ) { }
            }

        } message: {

            Text(updateMessage)
        }
    }
    private func checkForAppUpdate()
    async {

        let result =
            await
            MobileVersionService
                .shared
                .checkIosVersion()

        await MainActor.run {

            switch result {

            case .current:
                break

            case .updateAvailable(
                let info
            ):

                updateRequired = false

                updateMessage =
                    info.updateMessage

                appStoreUrl =
                    info.appStoreUrl

                showUpdateAlert = true

            case .updateRequired(
                let info
            ):

                updateRequired = true

                updateMessage =
                    info.updateMessage

                appStoreUrl =
                    info.appStoreUrl

                showUpdateAlert = true
            }
        }
    }
}
