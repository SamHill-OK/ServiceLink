//
//  CreateElderMeetingView.swift
//  ServiceLink
//
//  Created by Michael Anderson on 6/11/26.
//

import SwiftUI

struct CreateElderMeetingView: View {

    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = CreateElderMeetingViewModel()

    var body: some View {
        NavigationStack {
            Form {
                Section("Meeting") {
                    TextField("Title (optional)", text: $vm.title)

                    DatePicker(
                        "Date & Time",
                        selection: $vm.meetingDate,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }

                Section("Notes") {
                    TextEditor(text: $vm.notes)
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
                            let ok = await vm.save()

                            if ok {
                                dismiss()
                            }
                        }
                    }
                    .disabled(vm.isSaving)
                }
            }
            .onAppear {
                if let session = appState.session {
                    vm.configure(session: session)
                }
            }
        }
    }
}
