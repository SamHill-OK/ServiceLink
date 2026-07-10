//
//  EditElderMeetingViewModel.swift
//  ServiceLink
//
//  Created by Michael Anderson on 6/12/26.
//

import Foundation
import Combine

@MainActor
final class EditElderMeetingViewModel: ObservableObject {

    @Published var session: ServiceLinkSession?
    @Published var transcriptNote: ElderMeetingNoteDto?
    @Published var summaryNote: ElderMeetingNoteDto?
    @Published var noteError: String?

    func configure(session: ServiceLinkSession) {
        self.session = session
    }

    func updateMeeting(
        meetingId: Int,
        title: String,
        meetingDate: Date,
        notes: String
    ) async -> Bool {

        guard let session else { return false }

        guard let url = URL(
            string: "\(ApiConfig.baseUrl)/api/eldertools/meeting/update"
        ) else {
            return false
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        request.setValue(
            String(session.clientId),
            forHTTPHeaderField: "X-ClientID"
        )

        request.setValue(
            String(session.memberId),
            forHTTPHeaderField: "X-UserID"
        )

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

        let payload: [String: Any] = [
            "elderMeetingId": meetingId,
            "meetingTitle": title,
            "meetingDate": formatter.string(from: meetingDate),
            "notes": notes
        ]

        do {

            request.httpBody =
                try JSONSerialization.data(
                    withJSONObject: payload
                )

            let (_, response) =
                try await URLSession.shared.data(
                    for: request
                )

            return (response as? HTTPURLResponse)?
                .statusCode == 200

        } catch {

            print("❌ updateMeeting:", error)
            return false
        }
    }
    func loadTranscript(meetingId: Int) async {
        guard let session else { return }

        noteError = nil

        do {
            transcriptNote = try await ApiClient.shared.getMeetingNote(
                clientId: session.clientId,
                userId: session.memberId,
                elderMeetingId: meetingId,
                noteType: .transcript
            )
        } catch {
            print("❌ loadTranscript:", error)
            noteError = "Could not load transcript."
        }
    }
    func saveTranscript(
        meetingId: Int,
        title: String,
        markdown: String
    ) async -> Bool {
        guard let session else { return false }

        do {
            try await ApiClient.shared.saveMeetingNote(
                clientId: session.clientId,
                userId: session.memberId,
                elderMeetingId: meetingId,
                noteType: .transcript,
                noteTitle: title.isEmpty ? "Meeting Transcript" : title,
                noteMarkdown: markdown
            )

            noteError = nil
            return true
        } catch {
            print("❌ saveTranscript:", error)
            noteError = "Could not save transcript."
            return false
        }
    }
    
    func deleteTranscript(meetingId: Int) async -> Bool {
        guard let session else { return false }

        do {
            try await ApiClient.shared.deleteMeetingNote(
                clientId: session.clientId,
                userId: session.memberId,
                elderMeetingId: meetingId,
                noteType: .transcript
            )

            transcriptNote = nil
            noteError = nil
            return true
        } catch {
            print("❌ deleteTranscript:", error)
            noteError = "Could not delete transcript."
            return false
        }
    }
    
    func loadSummary(meetingId: Int) async {
        guard let session else { return }

        noteError = nil

        do {
            summaryNote = try await ApiClient.shared.getMeetingNote(
                clientId: session.clientId,
                userId: session.memberId,
                elderMeetingId: meetingId,
                noteType: .summary
            )
        } catch {
            print("❌ loadSummary:", error)
            noteError = "Could not load summary."
        }
    }
    func saveSummary(
        meetingId: Int,
        title: String,
        markdown: String
    ) async -> Bool {
        guard let session else { return false }

        do {
            try await ApiClient.shared.saveMeetingNote(
                clientId: session.clientId,
                userId: session.memberId,
                elderMeetingId: meetingId,
                noteType: .summary,
                noteTitle: title.isEmpty ? "Meeting Summary" : title,
                noteMarkdown: markdown
            )

            noteError = nil
            return true

        } catch {
            print("❌ saveSummary:", error)
            noteError = "Could not save summary."
            return false
        }
    }
    func deleteSummary(meetingId: Int) async -> Bool {
        guard let session else { return false }

        do {
            try await ApiClient.shared.deleteMeetingNote(
                clientId: session.clientId,
                userId: session.memberId,
                elderMeetingId: meetingId,
                noteType: .summary
            )

            summaryNote = nil
            noteError = nil
            return true

        } catch {
            print("❌ deleteSummary:", error)
            noteError = "Could not delete summary."
            return false
        }
    }
}
