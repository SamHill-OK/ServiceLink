//
//  AddGoForwardView.swift
//  ServiceLink
//
//  Created by Michael Anderson on 6/11/26.
//

import SwiftUI

struct AddGoForwardView: View {

    @EnvironmentObject var appState: AppState
    @StateObject private var vm = GoForwardViewModel()

    var body: some View {

        VStack(spacing: 20) {

            TextField("Search by name, phone, email...", text: $vm.searchText)
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

           
            TextEditor(text: $vm.note)
                .frame(height: 120)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.gray.opacity(0.3))
                )

            Button {
                Task {
                    _ = await vm.save()
                }
            } label: {
                if vm.isSaving {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Save")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(
                vm.selectedMember == nil ||
                vm.note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            )
        }
        .padding()
        .navigationTitle("Go Forward Follow-Up")
        .onAppear {
            if let session = appState.session {
                vm.configure(session: session)
            }
        }
    }
}
