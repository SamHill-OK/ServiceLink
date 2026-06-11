//
//  ElderMeetingDetailModels.swift
//  ServiceLink
//
//  Created by Michael Anderson on 6/11/26.
//

import Foundation

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
    let meetingDate: String

    let notes: String?
    let canceledFlag: Bool

    var guests: [ElderMeetingGuestDto]
}
