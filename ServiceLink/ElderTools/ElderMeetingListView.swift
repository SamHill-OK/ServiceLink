//
//  ElderMeetingListView.swift
//  ServiceLink
//
//  Created by Michael Anderson on 6/1/26.
//
import SwiftUI

struct ElderMeetingListView: View {

    @ObservedObject var vm: ElderToolsViewModel

    var body: some View {

        List(vm.meetings) { meeting in

            NavigationLink {
                ElderMeetingDetailView(
                    vm: vm,
                    meetingId: meeting.elderMeetingId
                )
            } label: {

                VStack(alignment: .leading) {

                    Text(meeting.meetingTitle)
                        .font(.headline)

                    Text(
                        meeting.meetingDate.formatted(
                            date: .abbreviated,
                            time: .shortened
                        )
                    )
                    .font(.caption)

                    Label(
                        "\(meeting.guestCount) Guest\(meeting.guestCount == 1 ? "" : "s")",
                        systemImage: "person.2.fill"
                    )
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)
        }
        .navigationTitle("Meetings")
        
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    vm.isShowingCreateMeeting = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $vm.isShowingCreateMeeting) {
            CreateElderMeetingView(vm: vm)
        }
        
        .task {
            await vm.loadMeetings()
        }
    }
}
