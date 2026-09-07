//
//  DirectoryPhotoAccessModels.swift
//  ServiceLink
//
//  Created by Michael Anderson on 9/7/26.
//

import Foundation

struct DirectoryPhotoAccessResponse: Codable {

    let containerUrl: String
    let sas: String
    let expiresOn: String
}
