//
//  ElderMeetingListView.swift
//  ServiceLink
//
//  Created by Michael Anderson on 6/11/26.
//

import SwiftUI

struct ElderMeetingListView: View {

    @EnvironmentObject var appState: AppState
    @Environment(\.scenePhase) private var scenePhase
    
    @StateObject private var vm = ElderMeetingListViewModel()
    @State private var isShowingCreateMeeting = false
    

    var body: some View {
        
        ScrollView {
            
            VStack(spacing: 12) {
                
                if vm.isLoading {
                    
                    ProgressView()
                    
                } else if vm.meetings.isEmpty {
                    
                    Text("No upcoming meetings")
                        .foregroundStyle(.secondary)
                        .padding(.top, 40)
                    
                } else {
                    
                    ForEach(vm.meetings) { meeting in
                        
                        NavigationLink {
                            ElderMeetingDetailView(
                                elderMeetingId: meeting.elderMeetingId
                            )
                        } label: {
                            
                            VStack(alignment: .leading, spacing: 8) {
                                
                                Text(meeting.meetingTitle)
                                    .font(.headline)
                                
                                Text(formatMeetingDate(meeting.meetingDate))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                
                                HStack {
                                    
                                    Image(systemName: "person.2.fill")
                                    
                                    Text("\(meeting.guestCount) Guests")
                                        .font(.caption)
                                }
                                .foregroundStyle(.secondary)
                            }
                            
                            
                            .buttonStyle(.plain)
                            
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(.thinMaterial)
                            .clipShape(
                                RoundedRectangle(cornerRadius: 12)
                            )
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Meetings")
        .toolbar {
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isShowingCreateMeeting = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        await vm.loadMeetings()
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .disabled(vm.isLoading)
            }
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    ElderMeetingHistoryView()
                        .environmentObject(appState)
                } label: {
                    Image(systemName: "clock.arrow.circlepath")
                }
            }
        }
        .sheet(
            isPresented: $isShowingCreateMeeting,
            onDismiss: {
                Task {
                    await vm.loadMeetings(type: .future)
                }
            }
        ) {
            CreateElderMeetingView()
                .environmentObject(appState)
        }
        .task {
            guard scenePhase == .active else {
                return
            }
            
            guard let session = appState.session else {
                return
            }
            
            vm.configure(session: session)
            await vm.loadMeetings()
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else {
                return
            }
            
            guard let session = appState.session else {
                return
            }
            
            vm.configure(session: session)
            
            Task {
                await vm.loadMeetings()
            }
        }
    }
    private func formatMeetingDate(_ value: String) -> String {

        let input = DateFormatter()
        input.locale = Locale(identifier: "en_US_POSIX")
        input.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

        guard let date = input.date(from: value) else {
            return value
        }

        let output = DateFormatter()
        output.dateFormat = "EEEE, MMMM d, yyyy - h:mm a"

        return output.string(from: date)
    }
}
