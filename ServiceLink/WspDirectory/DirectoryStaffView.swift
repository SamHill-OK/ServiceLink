import SwiftUI

struct DirectoryStaffView: View {

    @EnvironmentObject var appState: AppState

    @StateObject private var vm =
        DirectoryStaffViewModel()

    var body: some View {

        Group {

            if vm.isLoading {

                ProgressView()

            } else if let error =
                        vm.errorMessage {

                ContentUnavailableView(
                    "Unable to Load Staff",
                    systemImage:
                        "exclamationmark.triangle",
                    description:
                        Text(error)
                )

            } else if vm.staff.isEmpty {

                ContentUnavailableView(
                    "No Staff",
                    systemImage:
                        "person.crop.rectangle.stack"
                )

            } else {

                List(vm.staff) { staffMember in
                    
                    NavigationLink {
                        DirectoryStaffDetailView(
                            staffMember: staffMember
                        )
                    } label: {
                        
                        HStack(spacing: 12) {
                            
                            staffPhoto(
                                staffMember
                            )
                            
                            VStack(
                                alignment: .leading,
                                spacing: 4
                            ) {
                                
                                Text(
                                    staffMember.memberName
                                )
                                .font(.headline)
                                
                                Text(
                                    staffMember.staffTitle
                                )
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                    
                }
            }
        }
        .task {

            await vm.load(
                appState: appState
            )
        }
    }

    @ViewBuilder
    private func staffPhoto(
        _ staffMember: DirectoryStaffMember
    ) -> some View {

        if let photoPath =
            staffMember.staffPhotoThumbnailUrl,
           let url = URL(
                string:
                    "\(ApiConfig.baseUrl)/\(photoPath)"
           ) {

            AsyncImage(url: url) { phase in

                switch phase {

                case .empty:

                    ProgressView()
                        .frame(
                            width: 80,
                            height: 80
                        )

                case .success(let image):

                    image
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: 80,
                            height: 80
                        )
                        .clipped()
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 12
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
                cornerRadius: 12
            )
            .fill(
                Color(.systemGray5)
            )

            Image(
                systemName:
                    "person.crop.square.fill"
            )
            .font(.system(size: 32))
            .foregroundStyle(.secondary)
        }
        .frame(
            width: 80,
            height: 80
        )
    }
}
