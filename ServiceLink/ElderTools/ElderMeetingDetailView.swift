//
//  ElderMeetingDetailView.swift
//  ServiceLink
//
//  Created by Michael Anderson on 6/1/26.
//

import SwiftUI

struct ElderMeetingDetailView: View {

    @ObservedObject var vm: ElderToolsViewModel
    @State private var isShowingEditMeeting = false
    @State private var isShowingCancelMeeting = false
    @Environment(\.dismiss) private var dismiss
    @State private var isShowingAddGuest = false
    @State private var selectedGuest: ElderMeetingGuestDto?
    //@State private var isShowingEditGuest = false
    
    let meetingId: Int

    var body: some View {

        ScrollView {

            if let meeting = vm.selectedMeeting {

                VStack(alignment: .leading, spacing: 18) {

                    VStack(alignment: .leading, spacing: 6) {

                        Text(meeting.meetingTitle)
                            .font(.title2)
                            .bold()

                        Text(
                            meeting.meetingDate.formatted(
                                date: .abbreviated,
                                time: .shortened
                            )
                        )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                        Text("\(meeting.guests.count) Guest\(meeting.guests.count == 1 ? "" : "s")")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        if let notes = meeting.notes,
                           !notes.isEmpty {

                            Text(notes)
                                .font(.body)
                                .padding(.top, 6)
                        }

                    }
                    .padding()
                    .frame(maxWidth: .infinity,
                           alignment: .leading)
                    .background(.white)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 22)
                    )

                    HStack {
                        Label("Guests", systemImage: "person.2")
                            .font(.headline)

                        Spacer()

                        Button {
                            isShowingAddGuest = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                        }
                    }

                    if meeting.guests.isEmpty {

                        Text("No guests added.")
                            .foregroundStyle(.secondary)

                    } else {

                        ForEach(meeting.guests) { guest in

                            Button {

                                //print("🎯 Guest tapped: \(guest.memberName)")

                                selectedGuest = guest
                                //isShowingEditGuest = true

                            } label: {

                                VStack(alignment: .leading,
                                       spacing: 4) {

                                    Text(guest.memberName)
                                        .font(.headline)

                                    if let guestTime = guest.guestTime,
                                       !guestTime.isEmpty {

                                        Text(formatGuestTime(guestTime))
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }

                                    if let phone = guest.phoneNumber,
                                       !phone.isEmpty {

                                        let cleanPhone = phone.filter { $0.isNumber }

                                        if let url = URL(string: "tel://\(cleanPhone)") {

                                            Link(destination: url) {
                                                Label(phone, systemImage: "phone.fill")
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                            }
                                        }
                                    }

                                    if let notes = guest.guestNotes,
                                       !notes.isEmpty {

                                        Text(notes)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .padding()
                                .frame(maxWidth: .infinity,
                                       alignment: .leading)
                                .background(.white)
                                .clipShape(
                                    RoundedRectangle(cornerRadius: 18)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding()

            } else {

                ProgressView("Loading meeting...")
                    .padding()
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Meeting")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {

            ToolbarItemGroup(placement: .topBarTrailing) {

                Button {

                    isShowingEditMeeting = true

                } label: {

                    Image(systemName: "pencil")

                }

                Button(role: .destructive) {

                    isShowingCancelMeeting = true

                } label: {

                    Image(systemName: "trash")

                }
            }
        }
        //------- S H E E T S ------------------------------
        .sheet(isPresented: $isShowingEditMeeting) {
            if let meeting = vm.selectedMeeting {
                EditElderMeetingView(
                    vm: vm,
                    meeting: meeting
                )
            }
        }
        .sheet(isPresented: $isShowingAddGuest) {
            if let meeting = vm.selectedMeeting {
                AddElderMeetingGuestView(
                    vm: vm,
                    meetingId: meetingId,
                    defaultGuestTime: meeting.meetingDate
                )
            }
        }
        .sheet(item: $selectedGuest) { guest in
            EditElderMeetingGuestView(
                vm: vm,
                meetingId: meetingId,
                guest: guest
            )
        }
        //-----------------------------------------------
        .task {
            await vm.loadMeetingDetail(
                meetingId: meetingId
            )
        }
        .confirmationDialog(
            "Cancel Meeting?",
            isPresented: $isShowingCancelMeeting
        ) {

            Button(
                "Cancel Meeting",
                role: .destructive
            ) {

                Task {
                    let ok = await vm.cancelMeeting(
                        meetingId: meetingId,
                        reason: "Canceled from ServiceLink"
                    )

                    if ok {
                        dismiss()
                    }
                }
            }

        }
    }

    private func formatGuestTime(
        _ value: String
    ) -> String {

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"

        guard let date =
                formatter.date(from: value)
        else {
            return value
        }

        formatter.dateFormat = "h:mm a"

        return formatter.string(from: date)
    }
}
