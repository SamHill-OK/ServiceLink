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
    
    @State private var showingFind = false
    @State private var findText = ""
    @State private var findMatches: [NSRange] = []
    @State private var currentFindMatch = 0
    @State private var summarySelection: NSRange?

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
            .task(id: meeting.elderMeetingId) {

                guard let session = appState.session else {
                    return
                }

                vm.configure(session: session)

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

                await vm.loadMeetingNotes(
                    meetingId: meeting.elderMeetingId
                )
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
                    VStack(spacing: 0) {

                        if showingFind {
                            summaryFindBar
                        }

                        Form {
                            Section("Title") {
                                TextField(
                                    "Summary title",
                                    text: $summaryTitle
                                )
                            }

                            Section("Summary") {
                                SearchableTextEditor(
                                    text: $summaryText,
                                    selection: $summarySelection
                                )
                                .frame(minHeight: 500)
                            }
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
                                closeSummaryFind()
                                showingSummaryEditor = false
                            }
                        }

                        ToolbarItem(
                            placement: .topBarTrailing
                        ) {
                            Button {
                                showingFind.toggle()

                                if !showingFind {
                                    closeSummaryFind()
                                }
                            } label: {
                                Image(systemName: "magnifyingglass")
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
                                        closeSummaryFind()
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
    private var summaryFindBar: some View {

        VStack(spacing: 8) {

            HStack(spacing: 8) {

                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)

                TextField(
                    "Find in Summary",
                    text: $findText
                )
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .onChange(of: findText) {
                    updateSummaryFindMatches()
                }

                Button("Done") {
                    closeSummaryFind()
                }
            }

            HStack {

                Button {
                    showPreviousSummaryMatch()
                } label: {
                    Image(systemName: "chevron.up")
                }
                .disabled(findMatches.isEmpty)

                Button {
                    showNextSummaryMatch()
                } label: {
                    Image(systemName: "chevron.down")
                }
                .disabled(findMatches.isEmpty)

                Spacer()

                if findText.isEmpty {
                    Text("Enter text to find")
                        .foregroundStyle(.secondary)
                } else if findMatches.isEmpty {
                    Text("No matches")
                        .foregroundStyle(.secondary)
                } else {
                    Text(
                        "\(currentFindMatch + 1) of \(findMatches.count)"
                    )
                    .foregroundStyle(.secondary)
                }
            }
            .font(.subheadline)
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
    }
    private func updateSummaryFindMatches() {

        findMatches.removeAll()
        currentFindMatch = 0
        summarySelection = nil

        guard !findText.isEmpty else {
            return
        }

        let source = summaryText as NSString
        var searchRange = NSRange(
            location: 0,
            length: source.length
        )

        while searchRange.location < source.length {

            let match = source.range(
                of: findText,
                options: [.caseInsensitive],
                range: searchRange
            )

            guard match.location != NSNotFound else {
                break
            }

            findMatches.append(match)

            let nextLocation =
                match.location + max(match.length, 1)

            searchRange = NSRange(
                location: nextLocation,
                length: source.length - nextLocation
            )
        }

        if !findMatches.isEmpty {
            summarySelection = findMatches[0]
        }
    }

    private func showNextSummaryMatch() {

        guard !findMatches.isEmpty else {
            return
        }

        currentFindMatch =
            (currentFindMatch + 1) % findMatches.count

        summarySelection =
            findMatches[currentFindMatch]
    }

    private func showPreviousSummaryMatch() {

        guard !findMatches.isEmpty else {
            return
        }

        currentFindMatch =
            currentFindMatch == 0
                ? findMatches.count - 1
                : currentFindMatch - 1

        summarySelection =
            findMatches[currentFindMatch]
    }

    private func closeSummaryFind() {

        showingFind = false
        findText = ""
        findMatches.removeAll()
        currentFindMatch = 0
        summarySelection = nil
    }
}



private struct SearchableTextEditor: UIViewRepresentable {

    @Binding var text: String
    @Binding var selection: NSRange?

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(
        context: Context
    ) -> UITextView {

        let textView = UITextView()

        textView.delegate = context.coordinator
        textView.font =
            UIFont.preferredFont(forTextStyle: .body)

        textView.adjustsFontForContentSizeCategory = true
        textView.backgroundColor = .clear
        textView.isScrollEnabled = true
        textView.alwaysBounceVertical = true
        textView.keyboardDismissMode = .interactive

        textView.textContainerInset = UIEdgeInsets(
            top: 8,
            left: 4,
            bottom: 8,
            right: 4
        )

        textView.textContainer.lineFragmentPadding = 0

        return textView
    }

    func updateUIView(
        _ textView: UITextView,
        context: Context
    ) {

        let font =
            UIFont.preferredFont(forTextStyle: .body)

        let attributedText =
            NSMutableAttributedString(
                string: text,
                attributes: [
                    .font: font,
                    .foregroundColor:
                        UIColor.label
                ]
            )

        if let selection,
           selection.location != NSNotFound,
           selection.location + selection.length
                <= attributedText.length {

            attributedText.addAttribute(
                .backgroundColor,
                value: UIColor.systemYellow
                    .withAlphaComponent(0.55),
                range: selection
            )
        }

        if textView.attributedText != attributedText {

            let existingSelectedRange =
                textView.selectedRange

            textView.attributedText =
                attributedText

            if existingSelectedRange.location
                <= attributedText.length {

                textView.selectedRange =
                    existingSelectedRange
            }
        }

        guard let selection,
              selection.location != NSNotFound,
              selection.location + selection.length
                <= attributedText.length else {

            context.coordinator.lastScrolledRange = nil
            return
        }

        guard context.coordinator.lastScrolledRange
                != selection else {
            return
        }

        context.coordinator.lastScrolledRange =
            selection

        DispatchQueue.main.async {

            textView.layoutIfNeeded()

            let glyphRange =
                textView.layoutManager.glyphRange(
                    forCharacterRange: selection,
                    actualCharacterRange: nil
                )

            var matchRect =
                textView.layoutManager.boundingRect(
                    forGlyphRange: glyphRange,
                    in: textView.textContainer
                )

            matchRect.origin.x +=
                textView.textContainerInset.left

            matchRect.origin.y +=
                textView.textContainerInset.top

            let desiredY =
                matchRect.midY
                - (textView.bounds.height / 2)

            let maximumY =
                max(
                    0,
                    textView.contentSize.height
                    - textView.bounds.height
                    + textView.adjustedContentInset.bottom
                )

            let centeredY =
                min(
                    max(desiredY, 0),
                    maximumY
                )

            textView.setContentOffset(
                CGPoint(
                    x: 0,
                    y: centeredY
                ),
                animated: true
            )
        }
    }

    final class Coordinator:
        NSObject,
        UITextViewDelegate {

        private var parent: SearchableTextEditor

        var lastScrolledRange: NSRange?

        init(parent: SearchableTextEditor) {
            self.parent = parent
        }

        func textViewDidChange(
            _ textView: UITextView
        ) {
            parent.text = textView.text
            lastScrolledRange = nil
        }
    }
}
