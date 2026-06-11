//
//  EotmView.swift
//  ServiceLink
//
//  Created by Michael Anderson on 6/10/26.
//

import SwiftUI

struct EotmView: View {

    @ObservedObject var vm: EotmViewModel

    @State private var swapMode = false
    @State private var selectedForSwap: Set<Int> = []
    @State private var showSwapConfirm = false
    @State private var hasLoaded = false
    @State private var selectedEotm: EotmDto?

    var body: some View {

        List {
            ForEach(vm.eotmList) { item in
                EotmRow(
                    item: item,
                    swapMode: swapMode,
                    isSelected: selectedForSwap.contains(item.id),
                    isCurrent: isCurrent(item)
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    guard vm.session?.isAdmin == true else { return }

                    if swapMode {
                        toggleSwapSelection(item.id)
                    } else {
                        selectedEotm = item
                    }
                }
            }
        }
        .navigationTitle("Elder of the Month")
        .toolbar {
            if vm.session?.isAdmin == true {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(swapMode ? "Swap" : "Swap") {
                        if swapMode {
                            if selectedForSwap.count == 2 {
                                showSwapConfirm = true
                            }
                        } else {
                            swapMode = true
                        }
                    }
                    .disabled(swapMode && selectedForSwap.count != 2)
                }

                if swapMode {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            swapMode = false
                            selectedForSwap.removeAll()
                        }
                    }
                }
            }

            ToolbarItem(placement: .bottomBar) {
                Button {
                    Task {
                        await vm.load()
                    }
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
            }
        }
        .sheet(item: $selectedEotm) { item in
            NavigationStack {
                List(vm.eotmElders) { elder in
                    Button {
                        Task {
                            await vm.replaceEotm(
                                eotmId: item.id,
                                newElderId: elder.memberId
                            )

                            selectedEotm = nil
                        }
                    } label: {
                        Text(elder.elderName)
                    }
                }
                .navigationTitle("Select Elder")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Close") {
                            selectedEotm = nil
                        }
                    }
                }
            }
        }
        .alert("Swap Elders?", isPresented: $showSwapConfirm) {
            Button("Cancel", role: .cancel) {}

            Button("Swap", role: .destructive) {
                let ids = Array(selectedForSwap)

                guard ids.count == 2 else { return }

                Task {
                    await vm.swapEotm(
                        firstId: ids[0],
                        secondId: ids[1]
                    )

                    swapMode = false
                    selectedForSwap.removeAll()
                }
            }
        } message: {
            Text("This will swap the selected months.")
        }
        .task {
            guard !hasLoaded else { return }
            hasLoaded = true
            await vm.load()
        }
    }

    private func isCurrent(_ item: EotmDto) -> Bool {
        let now = Date()
        let components = Calendar.current.dateComponents([.year, .month], from: now)

        return components.year == item.calYear &&
               components.month == item.calMonth
    }

    private func toggleSwapSelection(_ id: Int) {
        if selectedForSwap.contains(id) {
            selectedForSwap.remove(id)
        } else if selectedForSwap.count < 2 {
            selectedForSwap.insert(id)
        }
    }
}

private struct EotmRow: View {

    let item: EotmDto
    let swapMode: Bool
    let isSelected: Bool
    let isCurrent: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.monthName + " " + String(item.calYear))
                    .font(.headline)

                Text(item.elderName ?? "Unassigned")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if swapMode {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? .blue : .secondary)
            } else if isCurrent {
                Text("Current")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(6)
            }
        }
    }
}
