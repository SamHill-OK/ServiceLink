//
//  ElderMeetingModels.swift
//  ServiceLink
//
//  Created by Michael Anderson on 6/11/26.
//

import Foundation

enum MeetingNoteType: String, Codable {
    case transcript = "Transcript"
    case summary = "Summary"
}


struct ElderMeetingDto: Codable, Identifiable {

    let elderMeetingId: Int
    let meetingTitle: String
    let meetingDate: String
    let notes: String?
    let guestCount: Int
    let canceledFlag: Bool

    var id: Int { elderMeetingId }
}

struct ElderMeetingNoteDto: Codable {
    let noteType: MeetingNoteType
    let noteTitle: String?
    let noteMarkdown: String
    let createdDateUtc: String
    let createdByName: String?
}

struct SaveElderMeetingNoteRequest: Codable {
    let noteTitle: String?
    let noteMarkdown: String
}
