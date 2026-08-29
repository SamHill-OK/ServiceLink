//
//  DirectoryStaffDetailView.swift
//  ServiceLink
//
//  Created by Michael Anderson on 8/29/26.
//

import SwiftUI
import UIKit

struct DirectoryStaffDetailView: View {
    @Environment(\.openURL) private var openURL

    @State private var phoneToContact: String?
    
    
    let staffMember: DirectoryStaffMember

    var body: some View {

        ScrollView {

            VStack(spacing: 20) {

                staffPhoto

                Text(staffMember.memberName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text(staffMember.staffTitle)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                if let phone = staffMember.phoneNumber,
                   !phone.isEmpty {

                    Button {
                        phoneToContact = phone
                    } label: {

                        HStack {

                            Image(systemName: "phone.fill")

                            Text(formattedPhone(phone))

                            Spacer()

                            Button {
                                UIPasteboard.general.string = phone
                            } label: {
                                Image(systemName: "doc.on.doc")
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                    .buttonStyle(.plain)
                }

                if let email = staffMember.email,
                   !email.isEmpty {

                    HStack {

                        Button {
                            sendEmail(email)
                        } label: {

                            HStack {

                                Image(systemName: "envelope.fill")

                                Text(email)
                            }
                        }
                        .buttonStyle(.plain)

                        Spacer()

                        Button {
                            UIPasteboard.general.string = email
                        } label: {
                            Image(systemName: "doc.on.doc")
                        }
                        .buttonStyle(.borderless)
                    }
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Staff")
        .navigationBarTitleDisplayMode(.inline)
        
        .confirmationDialog(
            "Contact \(staffMember.memberName)",
            isPresented: Binding(
                get: {
                    phoneToContact != nil
                },
                set: { newValue in
                    if !newValue {
                        phoneToContact = nil
                    }
                }
            )
        ) {

            if let phone = phoneToContact {

                Button("Call") {
                    call(phone)
                }

                Button("Message") {
                    message(
                        staffMember.smsNumber ?? phone
                    )
                }
            }

            Button("Cancel", role: .cancel) {
                phoneToContact = nil
            }
        }
        
    }
    @ViewBuilder
    private var staffPhoto: some View {

        if let photoPath = staffMember.staffPhotoUrl,
           let url = URL(
                string: "\(ApiConfig.baseUrl)/\(photoPath)"
           ) {

            AsyncImage(url: url) { phase in

                switch phase {

                case .empty:

                    ProgressView()
                        .frame(
                            maxWidth: .infinity,
                            minHeight: 300
                        )

                case .success(let image):

                    image
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 16
                            )
                        )

                case .failure:

                    staffPlaceholder

                @unknown default:

                    staffPlaceholder
                }
            }

        } else {

            staffPlaceholder
        }
    }
    private var staffPlaceholder: some View {

        ZStack {

            RoundedRectangle(
                cornerRadius: 16
            )
            .fill(
                Color(.systemGray5)
            )

            Image(
                systemName:
                    "person.crop.square.fill"
            )
            .font(.system(size: 70))
            .foregroundStyle(.secondary)
        }
        .frame(
            maxWidth: .infinity,
            minHeight: 300
        )
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
    private func formattedPhone(_ phone: String) -> String {

        let digits = phone.filter { $0.isNumber }

        guard digits.count == 10 else {
            return phone
        }

        let areaCode = digits.prefix(3)

        let prefix = digits
            .dropFirst(3)
            .prefix(3)

        let lineNumber = digits
            .dropFirst(6)

        return "(\(areaCode)) \(prefix)-\(lineNumber)"
    }
}
