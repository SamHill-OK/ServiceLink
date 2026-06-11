//
//  EditGoForwardView.swift
//  ServiceLink
//
//  Created by Michael Anderson on 6/11/26.
//

import SwiftUI

struct EditGoForwardView: View {

    @ObservedObject var vm: ReachOutViewModel
    let item: GoForwardRecentDto

    @Environment(\.dismiss) private var dismiss

    @State private var note: String
    @State private var resolved = false
    @State private var isSaving = false

    init(vm: ReachOutViewModel, item: GoForwardRecentDto) {
        self.vm = vm
        self.item = item
        _note = State(initialValue: item.note)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Member") {
                    Text("\(item.firstName) \(item.lastName)")
                        .font(.headline)
                }

                Section("Note") {
                    TextEditor(text: $note)
                        .frame(minHeight: 120)
                }

                Section {
                    Toggle("Mark Resolved", isOn: $resolved)
                }
            }
            .navigationTitle("Edit Follow-Up")
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

                            await vm.updateGoForward(
                                id: item.goForwardId,
                                note: note,
                                resolved: resolved
                            )

                            isSaving = false
                            dismiss()
                        }
                    }
                    .disabled(isSaving || note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
