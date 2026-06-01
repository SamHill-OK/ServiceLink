//
//  EditElderMeetingView.swift
//  ServiceLink
//
//  Created by Michael Anderson on 6/1/26.
//

import SwiftUI

struct EditElderMeetingView: View {

    @ObservedObject var vm: ElderToolsViewModel
    @Environment(\.dismiss) private var dismiss

    let meeting: ElderMeetingDetailDto

    @State private var title: String
    @State private var meetingDate: Date
    @State private var notes: String
    @State private var isSaving = false

    init(
        vm: ElderToolsViewModel,
        meeting: ElderMeetingDetailDto
    ) {
        self.vm = vm
        self.meeting = meeting

        _title = State(initialValue: meeting.meetingTitle)
        _meetingDate = State(initialValue: meeting.meetingDate)
        _notes = State(initialValue: meeting.notes ?? "")
    }

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
            .navigationTitle("Edit Meeting")
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

                            let ok = await vm.updateMeeting(
                                meetingId: meeting.elderMeetingId,
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
