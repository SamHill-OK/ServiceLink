//
//  CongregationSelectionView.swift
//  ServiceLink
//
//  Created by Michael Anderson on 7/28/26.
//

import SwiftUI

struct CongregationSelectionView: View {

    @EnvironmentObject var appState: AppState

    var body: some View {

        NavigationStack {

            List(
                appState.availableCongregations
            ) { congregation in

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
                    .padding(.vertical, 6)
                }
                .buttonStyle(.plain)
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
