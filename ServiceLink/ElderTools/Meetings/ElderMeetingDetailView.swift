//
//  ElderMeetingDetailView.swift
//  ServiceLink
//
//  Created by Michael Anderson on 6/11/26.
//

import SwiftUI

struct ElderMeetingDetailView: View {

    let elderMeetingId: Int

    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @StateObject private var vm = ElderMeetingDetailViewModel()

    @State private var showingCancelAlert = false
    @State private var isShowingAddGuest = false
    @State private var isShowingEditMeeting = false
    @State private var guestToEdit: ElderMeetingGuestDto?
    @State private var guestToRemove: ElderMeetingGuestDto?
    @State private var showingRemoveGuestDialog = false

    @StateObject private var noteVM = EditElderMeetingViewModel()

    @State private var showingSummary = false
    @State private var showingTranscript = false
    
    var body: some View {

        ScrollView {

            if vm.isLoading {

                ProgressView()
                    .padding()

            } else if let meeting = vm.meeting {

                VStack(alignment: .leading, spacing: 16) {

                    Text(formatMeetingDate(meeting.meetingDate))
                        .foregroundStyle(.secondary)

                    if let notes = meeting.notes,
                       !notes.isEmpty {

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes")
                                .font(.headline)

                            Text(notes)
                        }
                    }
                    
                    if noteVM.summaryNote != nil ||
                        noteVM.transcriptNote != nil {

                        VStack(alignment: .leading, spacing: 12) {

                            Text("Meeting Documents")
                                .font(.headline)

                            if let summary = noteVM.summaryNote {

                                Button {
                                    showingSummary = true
                                } label: {
                                    meetingDocumentRow(
                                        title: summary.noteTitle ?? "Meeting Summary",
                                        subtitle: "Read Summary",
                                        systemImage: "doc.text.fill"
                                    )
                                }
                                .buttonStyle(.plain)
                            }

                            if let transcript = noteVM.transcriptNote {

                                Button {
                                    showingTranscript = true
                                } label: {
                                    meetingDocumentRow(
                                        title: transcript.noteTitle ?? "Meeting Transcript",
                                        subtitle: "Read Transcript",
                                        systemImage: "text.bubble.fill"
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    HStack {
                        Text("Guests")
                            .font(.headline)

                        Spacer()

                        Button {
                            isShowingAddGuest = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                        }
                    }

                    if meeting.guests.isEmpty {

                        Text("No guests added.")
                            .foregroundStyle(.secondary)

                    } else {

                        ForEach(meeting.guests) { guest in

                            guestCard(guest)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()

            } else {

                Text("Meeting not found")
                    .foregroundStyle(.secondary)
                    .padding()
            }
        }
        .navigationTitle(vm.meeting?.meetingTitle ?? "Meeting")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                   isShowingEditMeeting = true
                } label: {
                    Image(systemName: "pencil")
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button(role: .destructive) {
                    showingCancelAlert = true
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
        .alert("Cancel Meeting?", isPresented: $showingCancelAlert) {
            Button("Keep Meeting", role: .cancel) { }

            Button("Cancel Meeting", role: .destructive) {
                Task {
                    let ok = await vm.cancelMeeting(
                        elderMeetingId: elderMeetingId
                    )

                    if ok {
                        dismiss()
                    }
                }
            }
        } message: {
            Text("This meeting will no longer appear in the meeting list.")
        }
        .confirmationDialog(
            "Remove Guest?",
            isPresented: $showingRemoveGuestDialog,
            titleVisibility: .visible
        ) {
            Button("Remove Guest", role: .destructive) {
                Task {
                    if let guest = guestToRemove {
                        let ok = await vm.removeGuest(
                            elderMeetingGuestId: guest.elderMeetingGuestId
                        )

                        if ok {
                            await vm.loadMeeting(elderMeetingId: elderMeetingId)
                        }
                    }

                    guestToRemove = nil
                }
            }

            Button("Keep Guest", role: .cancel) {
                guestToRemove = nil
            }
        }
        .sheet(isPresented: $isShowingAddGuest, onDismiss: {
            Task {
                await vm.loadMeeting(elderMeetingId: elderMeetingId)
            }
        }) {
            if let meeting = vm.meeting {
                AddElderMeetingGuestView(
                    elderMeetingId: elderMeetingId,
                    meetingDate: meeting.meetingDate
                )
                .environmentObject(appState)
            }
        }
        
        .fullScreenCover(
            isPresented: $isShowingEditMeeting,
            onDismiss: {
                Task {
                    await reloadMeetingData()
                }
            }
        ) {
            if let meeting = vm.meeting {
                EditElderMeetingView(meeting: meeting)
                    .environmentObject(appState)
            }
        }
        .fullScreenCover(isPresented: $showingSummary) {
            if let note = noteVM.summaryNote {

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
        .fullScreenCover(isPresented: $showingTranscript) {
            if let note = noteVM.transcriptNote {

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
        .sheet(item: $guestToEdit, onDismiss: {
            Task {
                await vm.loadMeeting(elderMeetingId: elderMeetingId)
            }
        }) { guest in
            EditElderMeetingGuestView(
                elderMeetingId: elderMeetingId,
                guest: guest
            )
            .environmentObject(appState)
        }
         
        .task(id: elderMeetingId) {

            guard let session = appState.session else {
                return
            }

            vm.configure(session: session)
            noteVM.configure(session: session)

            await reloadMeetingData()
        }
    }

    private func reloadMeetingData() async {

        await vm.loadMeeting(
            elderMeetingId: elderMeetingId
        )

        await noteVM.loadMeetingNotes(
            meetingId: elderMeetingId
        )

        await noteVM.loadMeetingNotes(
            meetingId: elderMeetingId
        )
    }
    private func guestCard(_ guest: ElderMeetingGuestDto) -> some View {

        VStack(alignment: .leading, spacing: 6) {

            Text(guest.memberName)
                .font(.headline)

            if let guestTime = guest.guestTime,
               !guestTime.isEmpty {
                Text(formatGuestTime(guestTime))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if let phone = guest.phoneNumber,
               !phone.isEmpty,
               let url = URL(string: "tel:\(phone.filter { $0.isNumber })") {

                Link(destination: url) {
                    Label(formatPhone(phone), systemImage: "phone.fill")
                        .font(.caption)
                }
            }

            if let notes = guest.guestNotes,
               !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack {
                Spacer()

                Button {
                    guestToEdit = guest
                } label: {
                    Image(systemName: "pencil")
                }

                Spacer()
                    .frame(width: 40)

                Button(role: .destructive) {
                    guestToRemove = guest
                    showingRemoveGuestDialog = true
                } label: {
                    Image(systemName: "trash")
                }
            }
            .font(.title3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func formatGuestTime(_ value: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm:ss"

        guard let date = formatter.date(from: value) else {
            return value
        }

        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }

    private func formatPhone(_ phone: String) -> String {
        let digits = phone.filter { $0.isNumber }

        guard digits.count == 10 else {
            return phone
        }

        let area = digits.prefix(3)
        let prefix = digits.dropFirst(3).prefix(3)
        let line = digits.suffix(4)

        return "(\(area)) \(prefix)-\(line)"
    }

    private func formatMeetingDate(_ value: String) -> String {

        let input = DateFormatter()
        input.locale = Locale(identifier: "en_US_POSIX")
        input.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

        guard let date = input.date(from: value) else {
            return value
        }

        let output = DateFormatter()
        output.dateFormat = "EEEE, MMMM d, yyyy - h:mm a"

        return output.string(from: date)
    }
    private func meetingDocumentRow(
        title: String,
        subtitle: String,
        systemImage: String
    ) -> some View {

        HStack(spacing: 12) {

            Image(systemName: systemImage)
                .font(.title2)
                .foregroundStyle(.tint)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 3) {

                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.tertiary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial)
        .clipShape(
            RoundedRectangle(cornerRadius: 12)
        )
    }
}
