//
//  ReachOutView.swift
//  ServiceLink
//
//  Created by Michael Anderson on 5/28/26.
//

import SwiftUI

struct ReachOutView: View {

    @ObservedObject var vm: ElderToolsViewModel

    // ✅ Sheet selection
    @State private var selectedGoForward: GoForwardRecentDto?

    var body: some View {

        VStack(spacing: 16) {

            // 🔔 TOP SECTION — Follow-Up Panel (scrollable, height capped)
            if !vm.recentGoForwards.isEmpty {

                VStack(alignment: .leading, spacing: 8) {

                    Text("Members Needing Follow-Up")
                        .font(.headline)
                        .padding(.horizontal)

                    ScrollView {
                        VStack(spacing: 12) {

                            ForEach(vm.recentGoForwards) { item in
                                GoForwardCard(item: item)
                                    .onTapGesture {
                                        selectedGoForward = item
                                    }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                    }
                    .frame(maxHeight: 320)
                }
            }

            Divider()

            // 🔁 BOTTOM SECTION — Reach Out Action (always visible)
            VStack(spacing: 20) {

                if let member = vm.reachOutMember {

                    VStack(spacing: 8) {

                        Text("\(member.firstName) \(member.lastName)")
                            .font(.title2)

                        if let phone = member.phoneNumber,
                           let url = URL(string: "tel:\(phone)") {
                            Link("Call \(phone)", destination: url)
                        }
                    }

                    Button {
                        Task {
                            await vm.markReachOutContacted()
                            await vm.loadNextReachOut()
                        }
                    } label: {
                        Text("We Spoke")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                } else {

                    Button("Get Next") {
                        Task {
                            await vm.loadNextReachOut()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }

                Spacer()
            }
            .padding(.horizontal)

        }
        .navigationTitle("Connection Tool")
        .task {
            await vm.loadRecentGoForwards()
            await vm.loadNextReachOut()
        }
        .sheet(item: $selectedGoForward) { item in
            EditGoForwardView(vm: vm, item: item)
        }
    }
}

// MARK: - GoForward Card

private struct GoForwardCard: View {

    let item: GoForwardRecentDto

    var body: some View {

        VStack(alignment: .leading, spacing: 6) {

            HStack(alignment: .top) {
                Text("\(item.firstName) \(item.lastName)")
                    .font(.subheadline)
                    .bold()

                Spacer()

                // ✏️ subtle edit indicator
                Image(systemName: "pencil")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(item.note)
                .font(.caption)
                .foregroundStyle(.secondary)

            if let phone = item.phoneNumber,
               let url = URL(string: "tel:\(phone)") {
                Link("Call", destination: url)
                    .font(.caption)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)   // ✅ full width
        .padding()
        .background(.thinMaterial)
        .cornerRadius(12)
    }
}
