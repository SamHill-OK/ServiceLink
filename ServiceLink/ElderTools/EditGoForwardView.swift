//
//  EditGoForwardView.swift
//  ServiceLink
//
//  Created by Michael Anderson on 5/28/26.
//

import SwiftUI

struct EditGoForwardView: View {

    @ObservedObject var vm: ElderToolsViewModel
    let item: GoForwardRecentDto

    @Environment(\.dismiss) var dismiss
    @State private var note: String
    @State private var resolved: Bool = false

    init(vm: ElderToolsViewModel, item: GoForwardRecentDto) {
        self.vm = vm
        self.item = item
        _note = State(initialValue: item.note)
    }

    var body: some View {

        NavigationStack {
            VStack(spacing: 20) {

                Text("\(item.firstName) \(item.lastName)")
                    .font(.headline)

                TextEditor(text: $note)
                    .frame(height: 120)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(.gray.opacity(0.3)))

                Toggle("Mark Resolved", isOn: $resolved)

                Button("Save") {
                    Task {
                        await vm.updateGoForward(
                            id: item.goForwardId,
                            note: note,
                            resolved: resolved
                        )
                        dismiss()
                    }
                }
                .buttonStyle(.borderedProminent)

                Spacer()
            }
            .padding()
            .navigationTitle("Edit Follow-Up")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
