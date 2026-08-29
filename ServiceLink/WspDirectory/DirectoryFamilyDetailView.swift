//
//  DirectoryFamilyDetailView.swift
//  ServiceLink
//
//  Created by Michael Anderson on 8/16/26.
//

import SwiftUI
import UIKit

struct DirectoryFamilyDetailView: View {

    @EnvironmentObject var appState: AppState
    @Environment(\.openURL) private var openURL

    let wspFamilyId: Int

    @StateObject private var vm =
        DirectoryFamilyDetailViewModel()

    var body: some View {

        Group {

            if vm.isLoading {

                ProgressView()

            } else if let error =
                        vm.errorMessage {

                ContentUnavailableView(
                    "Unable to Load Family",
                    systemImage:
                        "exclamationmark.triangle",
                    description:
                        Text(error)
                )

            } else if let family = vm.family {

                List {
                    if let photoPath = family.familyPhotoUrl,
                       let url = URL(
                            string:
                                "\(ApiConfig.baseUrl)/\(photoPath)"
                       ) {

                        Section {

                            AsyncImage(url: url) { phase in

                                switch phase {

                                case .empty:

                                    HStack {
                                        Spacer()
                                        ProgressView()
                                        Spacer()
                                    }
                                    .frame(height: 220)

                                case .success(let image):

                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxWidth: .infinity)
                                        .clipShape(
                                            RoundedRectangle(
                                                cornerRadius: 14
                                            )
                                        )

                                case .failure:

                                    familyPhotoPlaceholder

                                @unknown default:

                                    familyPhotoPlaceholder
                                }
                            }
                            .listRowInsets(
                                EdgeInsets(
                                    top: 12,
                                    leading: 16,
                                    bottom: 12,
                                    trailing: 16
                                )
                            )
                        }

                    } else {

                        Section {
                            familyPhotoPlaceholder
                        }
                    }
                    Section("Family") {

                        Text(family.displayName)
                            .font(.headline)
                        if let anniversaryText =
                            formattedAnniversary(family) {

                            HStack(spacing: 6) {

                                Image(systemName: "heart.fill")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                Text(anniversaryText)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        let addressLines = [
                            family.addr1,
                            family.addr2
                        ]
                        .compactMap { $0 }
                        .filter { !$0.isEmpty }

                        let cityStateZip = [
                            family.adCity,
                            family.adState,
                            family.adZip
                        ]
                        .compactMap { $0 }
                        .filter { !$0.isEmpty }
                        .joined(separator: " ")

                        let fullAddress = (
                            addressLines + [cityStateZip]
                        )
                        .filter { !$0.isEmpty }
                        .joined(separator: ", ")

                        if !fullAddress.isEmpty {

                            Button {
                                openMaps(fullAddress)
                            } label: {

                                HStack(alignment: .top, spacing: 10) {

                                    Image(systemName: "map.fill")
                                        .foregroundStyle(.blue)

                                    VStack(
                                        alignment: .leading,
                                        spacing: 2
                                    ) {

                                        ForEach(
                                            addressLines,
                                            id: \.self
                                        ) { line in

                                            Text(line)
                                        }

                                        if !cityStateZip.isEmpty {
                                            Text(cityStateZip)
                                        }
                                    }

                                    Spacer()

                                    Image(
                                        systemName: "arrow.up.right.square"
                                    )
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    if !family.adults.isEmpty {

                        Section("Adults") {

                            ForEach(family.adults) { member in

                                DirectoryFamilyMemberRow(
                                    member: member
                                )
                            }
                        }
                    }

                    if !family.children.isEmpty {

                        Section("Children") {

                            ForEach(family.children) { member in

                                DirectoryFamilyMemberRow(
                                    member: member
                                )
                            }
                        }
                    }

                    if !family.unclassifiedMembers.isEmpty {

                        Section("Other Members") {

                            ForEach(
                                family.unclassifiedMembers
                            ) { member in

                                DirectoryFamilyMemberRow(
                                    member: member
                                )
                            }
                        }
                    }
                }

            } else {

                ProgressView()
            }
        }
        .navigationTitle(
            vm.family?.displayName ?? "Family"
        )
        .navigationBarTitleDisplayMode(.inline)
        .task {

            await vm.load(
                appState: appState,
                wspFamilyId: wspFamilyId
            )
        }
    }
    private func openMaps(_ address: String) {

        let encoded =
            address.addingPercentEncoding(
                withAllowedCharacters: .urlQueryAllowed
            )

        guard let encoded,
              let url = URL(
                string:
                    "https://maps.apple.com/?q=\(encoded)"
              )
        else {
            return
        }

        openURL(url)
    }
    private func formattedAnniversary(
        _ family: DirectoryFamilyDetail
    ) -> String? {

        guard let month = family.anniversaryMonth,
              let day = family.anniversaryDay
        else {
            return nil
        }

        var components = DateComponents()
        components.month = month
        components.day = day

        if let year = family.anniversaryYear {
            components.year = year
        } else {
            components.year = 2000
        }

        guard let date =
            Calendar.current.date(from: components)
        else {
            return nil
        }

        let formatter = DateFormatter()

        formatter.dateFormat =
            family.anniversaryYear != nil
            ? "MMMM d, yyyy"
            : "MMMM d"

        return formatter.string(from: date)
    }
    private var familyPhotoPlaceholder: some View {

        ZStack {

            RoundedRectangle(
                cornerRadius: 14
            )
            .fill(
                Color(.systemGray5)
            )

            Image(systemName: "person.2.fill")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
        }
        .frame(
            maxWidth: .infinity
        )
        .frame(height: 180)
    }
}

private struct DirectoryFamilyMemberRow: View {

    @Environment(\.openURL) private var openURL
    @State private var phoneToContact: String?

    let member: DirectoryFamilyMember

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: 6
        ) {

            Text(member.fullName)
                .font(.headline)

            if hasRoleOrBirthday {

                HStack(spacing: 8) {

                    if let familyRole = member.familyRole,
                       !familyRole.isEmpty {

                        Text(familyRole)
                    }

                    if let birthday = member.birthday {

                        HStack(spacing: 3) {

                            Image(
                                systemName:
                                    "birthday.cake.fill"
                            )

                            Text(
                                birthdayText(
                                    birthday
                                )
                            )
                        }
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            if let phone = member.phoneNumber,
               !phone.isEmpty {

                HStack(spacing: 8) {

                    Button {
                        phoneToContact = phone
                    } label: {
                        HStack(spacing: 5) {

                            Image(systemName: "phone.fill")
                                .font(.caption)

                            Text(phone)
                        }
                        .foregroundStyle(.blue)
                    }
                    .buttonStyle(.plain)

                    Button {
                        UIPasteboard.general.string = phone
                    } label: {
                        Image(systemName: "doc.on.doc")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.borderless)
                    .accessibilityLabel("Copy phone number")
                }
            }

            if let email = member.email,
               !email.isEmpty {

                HStack(spacing: 8) {

                    Button {
                        sendEmail(email)
                    } label: {
                        Text(email)
                            .foregroundStyle(.blue)
                    }
                    .buttonStyle(.plain)

                    Button {
                        UIPasteboard.general.string = email
                    } label: {
                        Image(systemName: "doc.on.doc")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.borderless)
                    .accessibilityLabel("Copy email")
                }
            }
        }
        .padding(.vertical, 2)
        .confirmationDialog(
            "Contact \(member.firstName)",
            isPresented: Binding(
                get: {
                    phoneToContact != nil
                },
                set: { newValue in
                    if !newValue {
                        phoneToContact = nil
                    }
                }
            ),
            titleVisibility: .visible
        ) {

            if let phone = phoneToContact {

                Button {
                    call(phone)
                } label: {
                    Label(
                        "Call",
                        systemImage: "phone"
                    )
                }

                Button {
                    message(phone)
                } label: {
                    Label(
                        "Message",
                        systemImage: "message"
                    )
                }
            }

            Button(
                "Cancel",
                role: .cancel
            ) {
                phoneToContact = nil
            }
        }
    }

    private func call(_ phone: String) {

        let cleaned =
            phone.filter {
                $0.isNumber || $0 == "+"
            }

        guard let url =
                URL(string: "tel:\(cleaned)")
        else {
            return
        }

        openURL(url)
    }
    private func message(_ phone: String) {

        let cleaned =
            phone.filter {
                $0.isNumber || $0 == "+"
            }

        guard let url =
                URL(string: "sms:\(cleaned)")
        else {
            return
        }

        openURL(url)
    }

    private func sendEmail(_ email: String) {

        guard let url =
                URL(string: "mailto:\(email)")
        else {
            return
        }

        openURL(url)
    }
    private var hasRoleOrBirthday: Bool {

        let hasRole =
            !(member.familyRole ?? "")
                .isEmpty

        return hasRole ||
               member.birthday != nil
    }

    private func birthdayText(
        _ birthday: Date
    ) -> String {

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"

        return formatter.string(
            from: birthday
        )
    }
    
}

