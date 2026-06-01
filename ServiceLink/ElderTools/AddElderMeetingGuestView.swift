//
//  AddElderMeetingGuestView.swift
//  ServiceLink
//
//  Created by Michael Anderson on 6/1/26.
//

import SwiftUI

struct AddElderMeetingGuestView: View {

    @ObservedObject var vm: ElderToolsViewModel
    @Environment(\.dismiss) private var dismiss

    let meetingId: Int
    let defaultGuestTime: Date

    @State private var searchText = ""
    @State private var selectedMember: MemberLookupDto?
    @State private var guestTime: Date
    @State private var useGuestTime = true
    @State private var notes = ""
    @State private var isSaving = false

    init(
        vm: ElderToolsViewModel,
        meetingId: Int,
        defaultGuestTime: Date
    ) {
        self.vm = vm
        self.meetingId = meetingId
        self.defaultGuestTime = defaultGuestTime

        _guestTime = State(initialValue: defaultGuestTime)
    }
    var body: some View {
        NavigationStack {
            Form {

                Section("Member") {
                    TextField("Search member", text: $searchText)
                        .onChange(of: searchText) { _, newValue in
                            Task {
                                await vm.searchMembers(query: newValue)
                            }
                        }

                    if let selectedMember {
                        HStack {
                            Text("\(selectedMember.firstName) \(selectedMember.lastName)")
                                .font(.headline)

                            Spacer()

                            Button("Change") {
                                self.selectedMember = nil
                            }
                        }
                    } else {
                        ForEach(vm.memberSearchResults, id: \.memberID) { member in
                            Button {
                                selectedMember = member
                                searchText = "\(member.firstName) \(member.lastName)"
                                vm.memberSearchResults = []
                            } label: {
                                VStack(alignment: .leading) {
                                    Text("\(member.firstName) \(member.lastName)")

                                    if let phone = member.phoneNumber,
                                       !phone.isEmpty {
                                        Text(phone)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }
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
            .navigationTitle("Add Guest")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            guard let selectedMember else { return }

                            isSaving = true

                            let ok = await vm.addMeetingGuest(
                                meetingId: meetingId,
                                memberId: selectedMember.memberID,
                                guestTime: useGuestTime ? guestTime : nil,
                                guestNotes: notes
                            )

                            isSaving = false

                            if ok {
                                dismiss()
                            }
                        }
                    }
                    .disabled(selectedMember == nil || isSaving)
                }
            }
        }
    }
}
