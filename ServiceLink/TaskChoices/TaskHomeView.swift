//
//  TaskHomeView.swift
//  ServiceLink
//
//  Created by Michael Anderson on 5/22/26.
//

import SwiftUI

struct TaskHomeView: View {

    var body: some View {

        NavigationStack {

            VStack(spacing: 24) {

                Spacer()

                Image(
                    systemName:
                        "person.3.sequence.fill"
                )
                .font(.system(
                    size: 72
                ))
                .foregroundStyle(
                    .secondary
                )

                Text(
                    "Task Preferences"
                )
                .font(.title)
                .bold()

                Text(
"""
View and manage your worship task preferences.

Coming soon.
"""
                )
                .multilineTextAlignment(
                    .center
                )
                .foregroundStyle(
                    .secondary
                )

                Spacer()

                Text(
                    "Powered by WSP"
                )
                .font(.caption)
                .foregroundStyle(
                    .secondary
                )
            }
            .padding()
            .navigationTitle(
                "TASK"
            )
        }
    }
}
