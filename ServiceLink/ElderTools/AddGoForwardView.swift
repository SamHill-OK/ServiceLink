//
//  AddGoForwardView.swift
//  ServiceLink
//
//  Created by Michael Anderson on 5/28/26.
//

import SwiftUI

struct AddGoForwardView: View {

    @ObservedObject var vm: ElderToolsViewModel
    @Environment(\.dismiss) var dismiss

    @State private var searchText = ""
    @State private var selectedMember: MemberLookupDto?
    @State private var note = ""
    @State private var isSaving = false
    @State private var errorMessage: String?

    var body: some View {

        NavigationStack {

            VStack(spacing: 20) {

                // 🔍 Member Search
                VStack(alignment: .leading, spacing: 8) {

                    Text("Select Member")
                        .font(.headline)

                    TextField("Search by name, phone, email...", text: $searchText)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: searchText) { _ in
                            Task {
                                await vm.searchMembers(query: searchText)
                            }
                        }

                    if !vm.memberSearchResults.isEmpty {
                        ScrollView {
                            VStack(spacing: 8) {
                                ForEach(vm.memberSearchResults) { member in
                                    Button {
                                        selectedMember = member
                                        searchText = "\(member.firstName) \(member.lastName)"
                                        vm.memberSearchResults = []
                                    } label: {
                                        HStack {
                                            Text("\(member.firstName) \(member.lastName)")
                                            Spacer()
                                        }
                                        .padding()
                                        .background(.thinMaterial)
                                        .cornerRadius(8)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .frame(maxHeight: 160)
                    }
                }

                // 📝 Note
                VStack(alignment: .leading, spacing: 8) {
                    Text("Note (Required)")
                        .font(.headline)

                    TextEditor(text: $note)
                        .frame(height: 120)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.gray.opacity(0.3))
                        )
                }

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                // 💾 Save Button
                Button {
                    Task {
                        await save()
                    }
                } label: {
                    if isSaving {
                        ProgressView()
                    } else {
                        Text("Save")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(selectedMember == nil || note.trimmingCharacters(in: .whitespaces).isEmpty)

                Spacer()
            }
            .padding()
            .navigationTitle("Add Go-Forward")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func save() async {

        guard let member = selectedMember else { return }

        isSaving = true
        errorMessage = nil

        let success = await vm.addGoForward(
            memberId: member.memberID,
            note: note
        )

        isSaving = false

        if success {
            await vm.loadRecentGoForwards()
            dismiss()
        } else {
            errorMessage = "This member was already added today."
        }
    }
}
