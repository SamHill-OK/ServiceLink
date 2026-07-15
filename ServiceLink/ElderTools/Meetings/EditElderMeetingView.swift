//
//  EditElderMeetingView.swift
//  ServiceLink
//
//  Created by Michael Anderson on 6/12/26.
//

import SwiftUI

struct EditElderMeetingView: View {

    let meeting: ElderMeetingDetailDto

    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @StateObject private var vm = EditElderMeetingViewModel()

    @State private var meetingTitle = ""
    @State private var meetingDate = Date()
    @State private var notes = ""
    
 
    @State private var showingTranscript = false
    @State private var showingDeleteTranscript = false
    
    @State private var showingTranscriptEditor = false
    @State private var transcriptTitle = ""
    @State private var transcriptText = ""
    
    @State private var showingSummary = false
    @State private var showingDeleteSummary = false

    @State private var showingSummaryEditor = false
    @State private var summaryTitle = ""
    @State private var summaryText = ""

    var body: some View {

        NavigationStack {

            Form {

                Section("Meeting") {

                    TextField(
                        "Title",
                        text: $meetingTitle
                    )

                    DatePicker(
                        "Date",
                        selection: $meetingDate
                    )
                }

                Section("Notes") {

                    TextEditor(text: $notes)
                        .frame(minHeight: 150)
                }
                
                Section("Summary") {

                    if let summaryNote = vm.summaryNote {

                        VStack(alignment: .leading, spacing: 8) {

                            Text(summaryNote.noteTitle ?? "Meeting Summary")
                                .font(.headline)

                            if let createdByName = summaryNote.createdByName {
                                Text("Added by \(createdByName)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Button("Read Summary") {
                                showingSummary = true
                            }
                            .buttonStyle(.borderless)

                            Button("Edit Summary") {
                                summaryTitle = summaryNote.noteTitle ?? "Meeting Summary"
                                summaryText = summaryNote.noteMarkdown
                                showingSummaryEditor = true
                            }
                            .buttonStyle(.borderless)

                            Button("Delete Summary", role: .destructive) {
                                showingDeleteSummary = true
                            }
                            .buttonStyle(.borderless)
                        }

                    } else {

                        Text("No summary attached.")
                            .foregroundStyle(.secondary)

                        Button("Add Summary") {
                            summaryTitle = "Meeting Summary"
                            summaryText = ""
                            showingSummaryEditor = true
                        }
                    }

                    if let noteError = vm.noteError {
                        Text(noteError)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
                
                Section("Transcript") {

                    if let externalNote = vm.transcriptNote {

                        VStack(alignment: .leading, spacing: 8) {

                            Text(externalNote.noteTitle ?? "Meeting Note")
                                .font(.headline)

                            if let createdByName = externalNote.createdByName {
                                Text("Added by \(createdByName)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Button("Read Transcript") {
                                showingTranscript = true
                            }
                            .buttonStyle(.borderless)

                            Button("Delete Transcript", role: .destructive) {
                                showingDeleteTranscript = true
                            }
                            .buttonStyle(.borderless)
                        }

                    } else {

                        Text("No transcript attached.")
                            .foregroundStyle(.secondary)

                        Button("Add Transcript") {
                            transcriptTitle = "Meeting Transcript"
                            transcriptText = ""
                            showingTranscriptEditor = true
                        }
                    }

                    if let noteError = vm.noteError {
                        Text(noteError)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                    
                }
                
                
                
            }
            .navigationTitle("Edit Meeting")
            .toolbar {

                ToolbarItem(
                    placement: .cancellationAction
                ) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(
                    placement: .confirmationAction
                ) {
                    Button("Save") {

                        Task {

                            let ok = await vm.updateMeeting(
                                meetingId: meeting.elderMeetingId,
                                title: meetingTitle,
                                meetingDate: meetingDate,
                                notes: notes
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
                    Task {
                        await vm.loadTranscript(
                            meetingId: meeting.elderMeetingId
                        )

                        await vm.loadSummary(
                            meetingId: meeting.elderMeetingId
                        )
                    }
                }

                meetingTitle = meeting.meetingTitle
                notes = meeting.notes ?? ""

                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "en_US_POSIX")
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

                if let date = formatter.date(
                    from: meeting.meetingDate
                ) {
                    meetingDate = date
                }
            }
            
            .fullScreenCover(isPresented: $showingTranscriptEditor) {
                NavigationStack {
                    Form {
                        Section("Title") {
                            TextField(
                                "Transcript title",
                                text: $transcriptTitle
                            )
                        }

                        Section("Transcript") {
                            TextEditor(text: $transcriptText)
                                .frame(minHeight: 500)
                        }
                    }
                    .navigationTitle("Add Transcript")
                    .toolbar {
                        ToolbarItem(
                            placement: .cancellationAction
                        ) {
                            Button("Cancel") {
                                showingTranscriptEditor = false
                            }
                        }

                        ToolbarItem(
                            placement: .confirmationAction
                        ) {
                            Button("Save") {
                                Task {
                                    let ok = await vm.saveTranscript(
                                        meetingId: meeting.elderMeetingId,
                                        title: transcriptTitle,
                                        markdown: transcriptText
                                    )

                                    if ok {
                                        showingTranscriptEditor = false

                                        await vm.loadTranscript(
                                            meetingId: meeting.elderMeetingId
                                        )
                                    }
                                }
                            }
                            .disabled(
                                transcriptText
                                    .trimmingCharacters(
                                        in: .whitespacesAndNewlines
                                    )
                                    .isEmpty
                            )
                        }
                    }
                }
            }

            .fullScreenCover(isPresented: $showingTranscript) {
                if let note = vm.transcriptNote {
                    NavigationStack {
                        MeetingNoteReaderView(
                            text: note.noteMarkdown
                        )
                        .navigationTitle(
                            note.noteTitle ?? "Meeting Transcript"
                        )
                        .toolbar {
                            ToolbarItem(
                                placement: .confirmationAction
                            ) {
                                Button("Done") {
                                    showingTranscript = false
                                }
                            }
                        }
                    }
                }
            }

            .fullScreenCover(isPresented: $showingSummaryEditor) {
                NavigationStack {
                    Form {
                        Section("Title") {
                            TextField(
                                "Summary title",
                                text: $summaryTitle
                            )
                        }

                        Section("Summary") {
                            TextEditor(text: $summaryText)
                                .frame(minHeight: 500)
                        }
                    }
                    .navigationTitle(
                        vm.summaryNote == nil
                            ? "Add Summary"
                            : "Edit Summary"
                    )
                    .toolbar {
                        ToolbarItem(
                            placement: .cancellationAction
                        ) {
                            Button("Cancel") {
                                showingSummaryEditor = false
                            }
                        }

                        ToolbarItem(
                            placement: .confirmationAction
                        ) {
                            Button("Save") {
                                Task {
                                    let ok = await vm.saveSummary(
                                        meetingId: meeting.elderMeetingId,
                                        title: summaryTitle,
                                        markdown: summaryText
                                    )

                                    if ok {
                                        showingSummaryEditor = false

                                        await vm.loadSummary(
                                            meetingId: meeting.elderMeetingId
                                        )
                                    }
                                }
                            }
                            .disabled(
                                summaryText
                                    .trimmingCharacters(
                                        in: .whitespacesAndNewlines
                                    )
                                    .isEmpty
                            )
                        }
                    }
                }
            }

            .fullScreenCover(isPresented: $showingSummary) {
                if let note = vm.summaryNote {
                    NavigationStack {
                        MeetingNoteReaderView(
                            text: note.noteMarkdown
                        )
                        .navigationTitle(
                            note.noteTitle ?? "Meeting Summary"
                        )
                        .toolbar {
                            ToolbarItem(
                                placement: .confirmationAction
                            ) {
                                Button("Done") {
                                    showingSummary = false
                                }
                            }
                        }
                    }
                }
            }
            .confirmationDialog(
                "Delete Transcript?",
                isPresented: $showingDeleteTranscript,
                titleVisibility: .visible
            ) {
                Button("Delete Transcript", role: .destructive) {
                    Task {
                        let ok = await vm.deleteTranscript(
                            meetingId: meeting.elderMeetingId
                        )

                        if ok {
                            showingTranscript = false
                        }
                    }
                }

                Button("Cancel", role: .cancel) {
                }
            } message: {
                Text("This will remove the transcript from this meeting.")
            }
            
            .confirmationDialog(
                "Delete Summary?",
                isPresented: $showingDeleteSummary,
                titleVisibility: .visible
            ) {
                Button("Delete Summary", role: .destructive) {
                    Task {
                        let ok = await vm.deleteSummary(
                            meetingId: meeting.elderMeetingId
                        )

                        if ok {
                            showingSummary = false
                        }
                    }
                }

                Button("Cancel", role: .cancel) {
                }
            } message: {
                Text("This will remove the summary from this meeting.")
            }
            
            
            
        }
        
    }
 
}
