//
//  AssignmentModels.swift
//  ServiceLink
//
//  Created by Michael Anderson on 5/22/26.
//

import Foundation

struct ServiceLinkAssignment: Codable, Identifiable {

    let id: Int

    let clientId: Int
    let memberId: Int

    let worshipDate: String
    let calendarDate: String?

    let worshipDay: String
    let worshipSession: String
    let worshipName: String

    let daySession: String
    let memberName: String

    let smsReply: String

    let taskClass: Int?
    let sortOrder: Int?
    let sessionOrder: Int
    let assignmentStatus: String
    
    var formattedCalendarDate: String {

            guard let calendarDate else {
                return worshipDate
            }

            let input = DateFormatter()
            input.dateFormat = "yyyy-MM-dd"

            guard let date =
                input.date(from: calendarDate)
            else {
                return calendarDate
            }

            let output = DateFormatter()
            output.dateFormat = "MM-dd-yyyy"

            return output.string(from: date)
        }
    
    var canDecline: Bool {

        let input = DateFormatter()
        input.dateFormat = "yyyy-MM-dd"

        guard let calendarDate,
              let date =
                input.date(from: calendarDate)
        else {
            return true
        }

        return Calendar.current
            .startOfDay(for: date)
            >
            Calendar.current
            .startOfDay(for: Date())
    }
}
