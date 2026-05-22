//
//  AssignmentDetailView.swift
//  ServiceLink
//
//  Created by Michael Anderson on 5/22/26.
//

import SwiftUI


struct AssignmentDetailView: View {
    
    let assignment: ServiceLinkAssignment
    
    @Environment(\.dismiss) private var dismiss

    @StateObject private var vm =
        AssignmentDetailViewModel()

    @State private var showConfirm = false

    var body: some View {

        VStack(alignment: .leading, spacing: 18) {

            Text(assignment.worshipName)
                .font(.largeTitle)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 10) {

                DetailRow(label: "Date", value: assignment.formattedCalendarDate)

                DetailRow(label: "Session", value: assignment.daySession)

                DetailRow(
                    label: "Status",
                    value: assignment.statusText
                )
            }

            Spacer()

            if assignment.canDecline {

                Button(role: .destructive) {
                    showConfirm = true
                } label: {
                    if vm.isSubmitting {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Can't Serve")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .confirmationDialog(
                    "Unable to serve?",
                    isPresented: $showConfirm
                ) {

                    Button(
                        "Confirm Decline",
                        role: .destructive
                    ) {

                        Task {

                            let success =
                                await vm.decline(
                                    assignment:
                                        assignment
                                )

                            if success {
                                dismiss()
                            }
                        }
                    }
                }

            } else {

                Text("This assignment can no longer be declined in the app.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .navigationTitle("Assignment Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DetailRow: View {

    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.title3)
        }
    }
}
