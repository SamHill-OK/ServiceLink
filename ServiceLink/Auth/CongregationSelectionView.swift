//
//  CongregationSelectionView.swift
//  ServiceLink
//
//  Created by Michael Anderson on 7/28/26.
//

import SwiftUI

struct CongregationSelectionView: View {

    @EnvironmentObject var appState: AppState
    
    @State private var congregationToRemove:
        LoginCongregation?

    @State private var isRemovingCongregation =
        false

    @State private var removeErrorMessage:
        String?
    
    var body: some View {

        NavigationStack {

            List(
                appState.availableCongregations
            ) { congregation in

                HStack {

                    Button {
                        selectCongregation(
                            congregation
                        )
                    } label: {

                        VStack(
                            alignment: .leading,
                            spacing: 4
                        ) {

                            Text(
                                congregation.clientName
                            )
                            .font(.headline)

                            Text(
                                congregation.memberName
                            )
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        }

                        Spacer()
                    }
                    .buttonStyle(.plain)

                    Button {
                        congregationToRemove =
                            congregation
                    } label: {

                        Image(
                            systemName: "trash"
                        )
                        .foregroundStyle(.red)
                    }
                    .buttonStyle(.plain)
                    .disabled(isRemovingCongregation)
                }
                .padding(.vertical, 6)
                }
                
            .confirmationDialog(
                "Remove Congregation?",
                isPresented: Binding(
                    get: {
                        congregationToRemove != nil
                    },
                    set: { isPresented in
                        if !isPresented {
                            congregationToRemove = nil
                        }
                    }
                ),
                titleVisibility: .visible
            ) {
                if let congregation =
                    congregationToRemove {

                    Button(
                        "Remove Yourself from \(congregation.clientName)",
                        role: .destructive
                    ) {
                        Task {
                            isRemovingCongregation =
                                true

                            defer {
                                isRemovingCongregation =
                                    false
                            }

                            do {
                                try await appState
                                    .removeCongregation(
                                        congregation
                                    )

                                congregationToRemove =
                                    nil

                            } catch {
                                removeErrorMessage =
                                    error.localizedDescription
                            }
                        }
                    }
                }

                Button(
                    "Cancel",
                    role: .cancel
                ) {
                    congregationToRemove =
                        nil
                }
            }
            .alert(
                "Unable to Remove Congregation",
                isPresented: Binding(
                    get: {
                        removeErrorMessage != nil
                    },
                    set: { isPresented in
                        if !isPresented {
                            removeErrorMessage = nil
                        }
                    }
                )
            ) {
                Button("OK") {
                    removeErrorMessage = nil
                }
            } message: {
                Text(
                    removeErrorMessage
                        ?? "An unexpected error occurred."
                )
            }
            .navigationTitle(
                "Choose Congregation"
            )
            .toolbar {

                ToolbarItem(
                    placement: .topBarLeading
                ) {

                    Button("Cancel") {
                        appState
                            .cancelCongregationSelection()
                    }
                }
            }
        }
    }

    private func selectCongregation(
        _ congregation: LoginCongregation
    ) {

        guard let response =
            appState.pendingLoginResponse
        else {
            return
        }

        appState.completeLogin(
            response: response,
            congregation: congregation
        )
    }
}
