//
//  EditElderMeetingGuestView.swift
//  ServiceLink
//
//  Created by Michael Anderson on 6/12/26.
//

import SwiftUI

struct EditElderMeetingGuestView: View {

    let elderMeetingId: Int
    let guest: ElderMeetingGuestDto

    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @StateObject private var vm = EditElderMeetingGuestViewModel()

    @State private var guestTime = Date()
    @State private var guestNotes = ""

    var body: some View {

        NavigationStack {

            Form {

                Section("Guest") {
                    Text(guest.memberName)
                        .font(.headline)
                }

                Section("Meeting Card") {

                    DatePicker(
                        "Time",
                        selection: $guestTime,
                        displayedComponents: .hourAndMinute
                    )

                    TextField(
                        "Notes",
                        text: $guestNotes,
                        axis: .vertical
                    )
                    .lineLimit(3...6)
                }
            }
            .navigationTitle("Edit Guest")
            .toolbar {

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            let ok = await vm.updateMeetingGuest(
                                elderMeetingGuestId: guest.elderMeetingGuestId,
                                guestTime: guestTime,
                                guestNotes: guestNotes
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

                guestNotes = guest.guestNotes ?? ""

                if let timeText = guest.guestTime,
                   !timeText.isEmpty {

                    let formatter = DateFormatter()
                    formatter.locale = Locale(identifier: "en_US_POSIX")
                    formatter.dateFormat = "HH:mm:ss"

                    if let date = formatter.date(from: timeText) {
                        guestTime = date
                    }
                }
            }
        }
    }
}
