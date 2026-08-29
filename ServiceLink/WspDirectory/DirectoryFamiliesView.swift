//
//  DirectoryFamiliesView.swift
//  ServiceLink
//
//  Created by Michael Anderson on 8/16/26.
//

import SwiftUI

struct DirectoryFamiliesView: View {

    @EnvironmentObject var appState: AppState

    @StateObject private var vm =
        DirectoryViewModel()

    @State private var searchText = ""

    var body: some View {

        Group {

            if vm.isLoading {

                ProgressView()

            } else if let error =
                        vm.errorMessage {

                ContentUnavailableView(
                    "Directory Error",
                    systemImage:
                        "exclamationmark.triangle",
                    description:
                        Text(error)
                )

            } else if vm.families.isEmpty {

                ContentUnavailableView(
                    searchText.isEmpty
                    ? "No Families"
                    : "No Matches",
                    systemImage: "person.2",
                    description:
                        searchText.isEmpty
                        ? nil
                        : Text(
                            "No families matched \"\(searchText)\"."
                        )
                )

            } else {

                List(vm.families) { family in

                    NavigationLink {

                        DirectoryFamilyDetailView(
                            wspFamilyId: family.wspFamilyId
                        )

                    } label: {

                        HStack(spacing: 12) {

                            if let photoPath = family.familyPhotoThumbnailUrl,
                               let url = URL(
                                    string:
                                        "\(ApiConfig.baseUrl)/\(photoPath)"
                               ) {

                                AsyncImage(url: url) { phase in

                                    switch phase {

                                    case .empty:
                                        ProgressView()
                                            .frame(
                                                width: 64,
                                                height: 64
                                            )

                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(
                                                width: 110,
                                                height: 90
                                            )
                                            .clipShape(
                                                RoundedRectangle(
                                                    cornerRadius: 12
                                                )
                                            )

                                    case .failure:
                                        familyPlaceholder

                                    @unknown default:
                                        familyPlaceholder
                                    }
                                }

                            } else {

                                familyPlaceholder
                            }

                            VStack(
                                alignment: .leading,
                                spacing: 4
                            ) {

                                Text(family.displayName)
                                    .font(.headline)

                                if !family.memberFirstNames.isEmpty {

                                    Text(family.memberFirstNames)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(2)
                                }

                                Text(
                                    "\(family.memberCount) member\(family.memberCount == 1 ? "" : "s")"
                                )
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .searchable(
            text: $searchText,
            prompt: "Search families"
        )
        .task {

            await vm.loadFamilies(
                appState: appState
            )
        }
        .task(id: searchText) {

            try? await Task.sleep(
                for: .milliseconds(300)
            )

            guard !Task.isCancelled else {
                return
            }

            await vm.loadFamilies(
                appState: appState,
                searchText:
                    searchText.isEmpty
                    ? nil
                    : searchText
            )
        }
    }
    private var familyPlaceholder: some View {

        ZStack {

            RoundedRectangle(
                cornerRadius: 10
            )
            .fill(
                Color(.systemGray5)
            )

            Image(systemName: "person.2.fill")
                .foregroundStyle(.secondary)
        }
        .frame(
            width: 64,
            height: 64
        )
    }
}
