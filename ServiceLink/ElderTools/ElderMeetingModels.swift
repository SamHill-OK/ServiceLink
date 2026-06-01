//
//  ElderMeetingModels.swift
//  ServiceLink
//
//  Created by Michael Anderson on 6/1/26.
//

import Foundation

struct ElderMeetingDto: Codable, Identifiable {

    let elderMeetingId: Int
    let meetingTitle: String
    let meetingDate: Date
    let notes: String?
    let guestCount: Int
    let canceledFlag: Bool

    var id: Int { elderMeetingId }
}

struct ElderMeetingGuestDto: Codable, Identifiable {

    let elderMeetingGuestId: Int
    let memberId: Int
    let memberName: String
    let phoneNumber: String?
    let guestTime: String?
    let guestNotes: String?

    var id: Int { elderMeetingGuestId }
}

struct ElderMeetingDetailDto: Codable {

    let elderMeetingId: Int
    let meetingTitle: String
    let meetingDate: Date
    let notes: String?
    let canceledFlag: Bool

    let guests: [ElderMeetingGuestDto]
}
