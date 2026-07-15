//
//  MeetingSummaryEditorView.swift
//  ServiceLink
//
//  Created by Michael Anderson on 7/15/26.
//

import SwiftUI

struct MeetingSummaryEditorView: View {

    let isNewSummary: Bool
    let onSave: (_ title: String, _ markdown: String) async -> Bool

    @Environment(\.dismiss) private var dismiss

    @State private var title: String
    @State private var markdown: String

    @State private var isSaving = false
    @State private var errorMessage: String?

    init(
        title: String,
        markdown: String,
        isNewSummary: Bool,
        onSave: @escaping (_ title: String, _ markdown: String) async -> Bool
    ) {
        self.isNewSummary = isNewSummary
        self.onSave = onSave

        _title = State(initialValue: title)
        _markdown = State(initialValue: markdown)
    }

    var body: some View {

        NavigationStack {

            VStack(spacing: 0) {

                titleArea

                Divider()

                TextEditor(text: $markdown)
                    .font(.body)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity
                    )
                    .scrollContentBackground(.hidden)
                    .background(Color(uiColor: .systemBackground))
            }
            .navigationTitle(
                isNewSummary
                    ? "Add Summary"
                    : "Edit Summary"
            )
            .navigationBarTitleDisplayMode(.large)
            .toolbar {

                ToolbarItem(
                    placement: .cancellationAction
                ) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isSaving)
                }

                ToolbarItem(
                    placement: .topBarTrailing
                ) {
                    Button {
                        // We will wire Find here next.
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                    .disabled(markdown.isEmpty || isSaving)
                }

                ToolbarItem(
                    placement: .confirmationAction
                ) {
                    Button("Save") {
                        save()
                    }
                    .disabled(
                        markdown
                            .trimmingCharacters(
                                in: .whitespacesAndNewlines
                            )
                            .isEmpty || isSaving
                    )
                }
            }
            .overlay {
                if isSaving {
                    ProgressView()
                }
            }
            .alert(
                "Unable to Save Summary",
                isPresented: Binding(
                    get: {
                        errorMessage != nil
                    },
                    set: { newValue in
                        if !newValue {
                            errorMessage = nil
                        }
                    }
                )
            ) {
                Button("OK", role: .cancel) {
                    errorMessage = nil
                }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    private var titleArea: some View {

        VStack(alignment: .leading, spacing: 8) {

            Text("Title")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            TextField(
                "Summary title",
                text: $title
            )
            .textFieldStyle(.roundedBorder)
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
    }

    private func save() {

        guard !isSaving else {
            return
        }

        isSaving = true
        errorMessage = nil

        Task {

            let ok = await onSave(
                title,
                markdown
            )

            await MainActor.run {

                isSaving = false

                if ok {
                    dismiss()
                } else {
                    errorMessage =
                        "The summary could not be saved. Please try again."
                }
            }
        }
    }
}
