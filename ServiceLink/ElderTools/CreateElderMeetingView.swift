//
//  CreateElderMeetingView.swift
//  ServiceLink
//
//  Created by Michael Anderson on 6/1/26.
//

import SwiftUI

struct CreateElderMeetingView: View {

    @ObservedObject var vm: ElderToolsViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var meetingDate = Date()
    @State private var notes = ""
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Meeting") {
                    TextField("Title (optional)", text: $title)

                    DatePicker(
                        "Date & Time",
                        selection: $meetingDate,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }

                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 120)
                }
            }
            .navigationTitle("New Meeting")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            isSaving = true

                            let ok = await vm.createMeeting(
                                title: title,
                                meetingDate: meetingDate,
                                notes: notes
                            )

                            isSaving = false

                            if ok {
                                dismiss()
                            }
                        }
                    }
                    .disabled(isSaving)
                }
            }
        }
    }
}
