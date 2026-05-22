//
//  AssignmentDetailView.swift
//  ServiceLink
//
//  Created by Michael Anderson on 5/22/26.
//

import SwiftUI

struct AssignmentDetailView: View {

    let assignment: ServiceLinkAssignment

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

            Button(role: .destructive) {
                // next step
            } label: {
                Text("Can't Serve")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
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
