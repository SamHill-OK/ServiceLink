//
//  DirectoryPhotoUrlBuilder.swift
//  ServiceLink
//
//  Created by Michael Anderson on 9/7/26.
//

import Foundation

enum DirectoryPhotoUrlBuilder {

    static func familyThumbnailUrl(
        access: DirectoryPhotoAccessResponse,
        wspFamilyId: Int
    ) -> URL? {

        buildUrl(
            access: access,
            blobPath:
                "families/\(wspFamilyId)/thumbnail.jpg"
        )
    }

    static func familyPhotoUrl(
        access: DirectoryPhotoAccessResponse,
        wspFamilyId: Int
    ) -> URL? {

        buildUrl(
            access: access,
            blobPath:
                "families/\(wspFamilyId)/photo.jpg"
        )
    }

    static func staffThumbnailUrl(
        access: DirectoryPhotoAccessResponse,
        directoryStaffId: Int
    ) -> URL? {

        buildUrl(
            access: access,
            blobPath:
                "staff/\(directoryStaffId)/thumbnail.jpg"
        )
    }

    static func staffPhotoUrl(
        access: DirectoryPhotoAccessResponse,
        directoryStaffId: Int
    ) -> URL? {

        buildUrl(
            access: access,
            blobPath:
                "staff/\(directoryStaffId)/photo.jpg"
        )
    }

    private static func buildUrl(
        access: DirectoryPhotoAccessResponse,
        blobPath: String
    ) -> URL? {

        let base =
            access.containerUrl
                .trimmingCharacters(
                    in: CharacterSet(
                        charactersIn: "/"
                    )
                )

        let sas =
            access.sas
                .trimmingCharacters(
                    in: CharacterSet(
                        charactersIn: "?"
                    )
                )

        return URL(
            string:
                "\(base)/\(blobPath)?\(sas)"
        )
    }
}
