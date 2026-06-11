//
//  ElderMeetingModels.swift
//  ServiceLink
//
//  Created by Michael Anderson on 6/11/26.
//

import Foundation

struct ElderMeetingDto: Codable, Identifiable {

    let elderMeetingId: Int
    let meetingTitle: String
    let meetingDate: String
    let notes: String?
    let guestCount: Int
    let canceledFlag: Bool

    var id: Int { elderMeetingId }
}
