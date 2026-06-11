//
//  ReachOutView.swift
//  ServiceLink
//
//  Created by Michael Anderson on 6/11/26.
//

import SwiftUI

struct ReachOutView: View {

    @EnvironmentObject var appState: AppState
    @StateObject private var vm = ReachOutViewModel()

    @State private var selectedGoForward: GoForwardRecentDto?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                if !vm.recentGoForwards.isEmpty {
                    goForwardSection
                }

                reachOutSection
            }
            .padding()
        }
        .navigationTitle("Connection Tool")
        .onAppear {
            if let session = appState.session {
                vm.configure(session: session)

                Task {
                    await vm.load()
                }
            }
        }
        .sheet(item: $selectedGoForward) { item in
            EditGoForwardView(vm: vm, item: item)
        }
    }

    private var goForwardSection: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text("Go Forward Follow-Up")
                .font(.headline)

            ForEach(vm.recentGoForwards) { item in
                GoForwardCard(item: item)
                    .onTapGesture {
                        selectedGoForward = item
                    }
            }
        }
    }

    private var reachOutSection: some View {
        VStack(spacing: 16) {

            if vm.isLoading {
                ProgressView()
            } else if let member = vm.reachOutMember {

                Text("\(member.firstName) \(member.lastName)")
                    .font(.title2)
                    .fontWeight(.semibold)

                if let phone = member.phoneNumber,
                   let url = URL(string: "tel:\(phone.filter { $0.isNumber })") {

                    Link(destination: url) {
                        Label(formatPhone(phone), systemImage: "phone.fill")
                            .font(.headline)
                    }
                }

                Button {
                    Task {
                        let ok = await vm.markContacted()

                        if ok {
                            await vm.load()
                        }
                    }
                } label: {
                    Text("We Spoke")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

            } else {
                Text("No member found")
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    private func formatPhone(_ phone: String) -> String {
        let digits = phone.filter { $0.isNumber }

        guard digits.count == 10 else {
            return phone
        }

        let area = digits.prefix(3)
        let prefix = digits.dropFirst(3).prefix(3)
        let line = digits.suffix(4)

        return "(\(area)) \(prefix)-\(line)"
    }
}

private struct GoForwardCard: View {

    let item: GoForwardRecentDto

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            HStack(alignment: .top) {
                Text("\(item.firstName) \(item.lastName)")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Spacer()

                Image(systemName: "pencil")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(item.note)
                .font(.caption)
                .foregroundStyle(.secondary)

            if let phone = item.phoneNumber,
               let url = URL(string: "tel:\(phone.filter { $0.isNumber })") {

                Link(destination: url) {
                    Label(formatPhone(phone), systemImage: "phone.fill")
                        .font(.caption)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func formatPhone(_ phone: String) -> String {
        let digits = phone.filter { $0.isNumber }

        guard digits.count == 10 else {
            return phone
        }

        let area = digits.prefix(3)
        let prefix = digits.dropFirst(3).prefix(3)
        let line = digits.suffix(4)

        return "(\(area)) \(prefix)-\(line)"
    }
}
