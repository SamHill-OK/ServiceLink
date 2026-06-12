//
//  EditElderMeetingView.swift
//  ServiceLink
//
//  Created by Michael Anderson on 6/12/26.
//

import SwiftUI

struct EditElderMeetingView: View {

    let meeting: ElderMeetingDetailDto

    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @StateObject private var vm = EditElderMeetingViewModel()

    @State private var meetingTitle = ""
    @State private var meetingDate = Date()
    @State private var notes = ""

    var body: some View {

        NavigationStack {

            Form {

                Section("Meeting") {

                    TextField(
                        "Title",
                        text: $meetingTitle
                    )

                    DatePicker(
                        "Date",
                        selection: $meetingDate
                    )
                }

                Section("Notes") {

                    TextEditor(text: $notes)
                        .frame(minHeight: 150)
                }
            }
            .navigationTitle("Edit Meeting")
            .toolbar {

                ToolbarItem(
                    placement: .cancellationAction
                ) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(
                    placement: .confirmationAction
                ) {
                    Button("Save") {

                        Task {

                            let ok = await vm.updateMeeting(
                                meetingId: meeting.elderMeetingId,
                                title: meetingTitle,
                                meetingDate: meetingDate,
                                notes: notes
                            )

                            if ok {
                                dismiss()
                            }
                        }
                    }
                }
            }
            .onAppear {

                if let session = appState.session {

                    vm.configure(session: session)
                }

                meetingTitle = meeting.meetingTitle
                notes = meeting.notes ?? ""

                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "en_US_POSIX")
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

                if let date = formatter.date(
                    from: meeting.meetingDate
                ) {
                    meetingDate = date
                }
            }
        }
    }
}
