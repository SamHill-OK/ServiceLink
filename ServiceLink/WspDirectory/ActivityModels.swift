//
//  ActivityModels.swift
//  ServiceLink
//
//  Created by Michael Anderson on 8/29/26.
//

struct ActivityDto: Codable, Identifiable {
    let activityId: Int
    let activityTemplateId: Int?
    let activityName: String
    let activityDescription: String?
    let location: String?
    let activityDate: String
    let startTime: String?
    let endTime: String?
    let allDayFlag: Bool
    let activeFlag: Bool

    var id: Int { activityId }
}
