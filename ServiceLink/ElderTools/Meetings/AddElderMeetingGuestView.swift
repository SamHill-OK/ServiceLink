//
//  AddElderMeetingGuestView.swift
//  ServiceLink
//
//  Created by Michael Anderson on 6/11/26.
//

import SwiftUI

struct AddElderMeetingGuestView: View {

    let elderMeetingId: Int
    let meetingDate: String

    @EnvironmentObject var appState: AppState
    @StateObject private var vm = AddElderMeetingGuestViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {

        NavigationStack {

            VStack(spacing: 16) {

                TextField(
                    "Search member...",
                    text: $vm.searchText
                )
                .textFieldStyle(.roundedBorder)
                .onChange(of: vm.searchText) { _, newValue in
                    Task {
                        await vm.searchMembers(query: newValue)
                    }
                }

                if let selected = vm.selectedMember {

                    VStack(alignment: .leading, spacing: 4) {

                        Text("\(selected.firstName) \(selected.lastName)")
                            .font(.headline)

                        if let phone = selected.phoneNumber {
                            Text(phone)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                if !vm.memberSearchResults.isEmpty {

                    List(vm.memberSearchResults) { member in

                        Button {

                            vm.selectedMember = member
                            vm.searchText = "\(member.firstName) \(member.lastName)"
                            vm.memberSearchResults = []

                        } label: {

                            VStack(alignment: .leading) {

                                Text("\(member.firstName) \(member.lastName)")

                                if let phone = member.phoneNumber {
                                    Text(phone)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        
                    }
                    .frame(height: 200)
                }

                
                DatePicker(
                    "Guest Time",
                    selection: $vm.guestTime,
                    displayedComponents: [.hourAndMinute]
                )

                TextEditor(text: $vm.guestNotes)
                    .frame(height: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.gray.opacity(0.3))
                    )

                Button {
                    Task {
                        let ok = await vm.save(
                            elderMeetingId: elderMeetingId
                        )

                        if ok {
                            dismiss()
                        }
                    }
                } label: {
                    if vm.isSaving {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Save Guest")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(vm.selectedMember == nil || vm.isSaving)
            }
            .padding()
            .navigationTitle("Add Guest")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {

                if let session = appState.session {
                    vm.configure(session: session);
                    vm.setDefaultGuestTime(from: meetingDate)
                }
            }
        }
    }
}
