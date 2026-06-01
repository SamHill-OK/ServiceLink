import SwiftUI

struct EditElderMeetingGuestView: View {

    @ObservedObject var vm: ElderToolsViewModel
    @Environment(\.dismiss) private var dismiss

    let meetingId: Int
    let guest: ElderMeetingGuestDto

    @State private var guestTime: Date
    @State private var useGuestTime = true
    @State private var notes: String
    @State private var isSaving = false
    @State private var isShowingRemoveConfirm = false

    init(
        vm: ElderToolsViewModel,
        meetingId: Int,
        guest: ElderMeetingGuestDto
    ) {
        self.vm = vm
        self.meetingId = meetingId
        self.guest = guest

        _guestTime = State(
            initialValue: Self.dateFromGuestTime(guest.guestTime)
        )
        _notes = State(initialValue: guest.guestNotes ?? "")
        _useGuestTime = State(initialValue: guest.guestTime != nil)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Guest") {
                    Text(guest.memberName)
                        .font(.headline)
                }

                Section("Guest Time") {
                    Toggle("Set guest time", isOn: $useGuestTime)

                    if useGuestTime {
                        DatePicker(
                            "Time",
                            selection: $guestTime,
                            displayedComponents: [.hourAndMinute]
                        )
                    }
                }

                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .safeAreaInset(edge: .bottom) {
                Button(role: .destructive) {
                    isShowingRemoveConfirm = true
                } label: {
                    Label("Remove Guest", systemImage: "trash")
                        .frame(maxWidth: .infinity)
                        .padding()
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
                            isSaving = true

                            let ok = await vm.updateMeetingGuest(
                                meetingId: meetingId,
                                elderMeetingGuestId: guest.elderMeetingGuestId,
                                guestTime: useGuestTime ? guestTime : nil,
                                guestNotes: notes
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
            .confirmationDialog(
                "Remove Guest?",
                isPresented: $isShowingRemoveConfirm
            ) {
                Button("Remove Guest", role: .destructive) {
                    Task {
                        let ok = await vm.removeMeetingGuest(
                            meetingId: meetingId,
                            elderMeetingGuestId: guest.elderMeetingGuestId
                        )

                        if ok {
                            dismiss()
                        }
                    }
                }
            }
        }
    }

    private static func dateFromGuestTime(_ value: String?) -> Date {
        guard let value,
              !value.isEmpty else {
            return Date()
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm:ss"

        return formatter.date(from: value) ?? Date()
    }
}//
//  EditElderMeetingGuestView.swift
//  ServiceLink
//
//  Created by Michael Anderson on 6/1/26.
//

