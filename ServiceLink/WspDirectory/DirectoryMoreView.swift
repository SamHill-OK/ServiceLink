import SwiftUI
import UIKit

struct DirectoryMoreView: View {

    @EnvironmentObject var appState: AppState

    @StateObject private var vm =
        DirectoryMoreViewModel()

    @State private var selectedTab:
        MoreTab = .activities

    @State private var selectedMonth =
        Date()
    @State private var selectedPhoneNumber: String?
    @State private var showPhoneActions = false
    
    var body: some View {

        VStack(spacing: 0) {

            monthSelector

            Picker(
                "More",
                selection: $selectedTab
            ) {

                ForEach(MoreTab.allCases) { tab in

                    Text(tab.title)
                        .tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.bottom, 8)

            Divider()

            Group {

                switch selectedTab {

                case .activities:

                    activitiesContent

                case .birthdays:

                    birthdaysContent

                case .anniversary:

                    anniversariesContent
                }
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
        }
        .task {
            await loadCurrentMonth()
        }
        .onChange(of: selectedTab) {
            Task {
                await loadCurrentMonth()
            }
        }
        .confirmationDialog(
            "Contact",
            isPresented: $showPhoneActions,
            titleVisibility: .visible
        ) {

            if let phone = selectedPhoneNumber {

                Button("Call") {
                    callPhone(phone)
                }

                Button("Text Message") {
                    textPhone(phone)
                }
            }

            Button(
                "Cancel",
                role: .cancel
            ) { }
        }
    }

    private var monthSelector: some View {

        HStack {

            Button {
                changeMonth(by: -1)
            } label: {

                Image(
                    systemName:
                        "chevron.left"
                )
            }

            Spacer()

            Text(monthTitle)
                .font(.headline)

            Spacer()

            Button {
                changeMonth(by: 1)
            } label: {

                Image(
                    systemName:
                        "chevron.right"
                )
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }

    @ViewBuilder
    private var activitiesContent: some View {

        if vm.isLoading {

            ProgressView()

        } else if let error =
                    vm.errorMessage {

            ContentUnavailableView(
                "Activity Error",
                systemImage:
                    "exclamationmark.triangle",
                description:
                    Text(error)
            )

        } else if vm.activities.isEmpty {

            ContentUnavailableView(
                "No Activities",
                systemImage:
                    "calendar",
                description:
                    Text(
                        "There are no activities scheduled for \(monthTitle)."
                    )
            )

        } else {

            List(vm.activities) { activity in

                VStack(
                    alignment: .leading,
                    spacing: 6
                ) {

                    Text(
                        activity.activityName
                    )
                    .font(.headline)

                    Text(
                        formatActivityDate(
                            activity.activityDate
                        )
                    )
                    .font(.subheadline)
                    .foregroundStyle(
                        .secondary
                    )

                    if activity.allDayFlag {

                        Text("All Day")
                            .font(.subheadline)
                            .foregroundStyle(
                                .secondary
                            )

                    } else if let timeText =
                                formatTimeRange(
                                    start:
                                        activity.startTime,
                                    end:
                                        activity.endTime
                                ) {

                        Text(timeText)
                            .font(.subheadline)
                            .foregroundStyle(
                                .secondary
                            )
                    }

                    if let location =
                        activity.location,
                       !location.isEmpty {

                        Label(
                            location,
                            systemImage:
                                "mappin.and.ellipse"
                        )
                        .font(.subheadline)
                    }

                    if let description =
                        activity.activityDescription,
                       !description.isEmpty {

                        Text(description)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.top, 3)
                    }
                }
                .padding(.vertical, 6)
            }
            .listStyle(.plain)
        }
    }

    private var monthTitle: String {

        selectedMonth.formatted(
            .dateTime
                .month(.wide)
                .year()
        )
    }

    private func changeMonth(
        by value: Int
    ) {

        guard let newDate =
            Calendar.current.date(
                byAdding: .month,
                value: value,
                to: selectedMonth
            )
        else {
            return
        }

        selectedMonth =
            newDate

        Task {
            await loadCurrentMonth()
        }
    }

    private func loadCurrentMonth() async {

        let components =
            Calendar.current.dateComponents(
                [.year, .month],
                from: selectedMonth
            )

        guard let year = components.year,
              let month = components.month
        else {
            return
        }

        switch selectedTab {

        case .activities:

            await vm.loadActivities(
                appState: appState,
                year: year,
                month: month
            )

        case .birthdays:

            await vm.loadBirthdays(
                appState: appState,
                year: year,
                month: month
            )

        case .anniversary:

            await vm.loadAnniversaries(
                appState: appState,
                year: year,
                month: month
            )
        }
    }

    private func formatActivityDate(
        _ value: String
    ) -> String {

        let formatter =
            DateFormatter()

        formatter.dateFormat =
            "yyyy-MM-dd"

        guard let date =
            formatter.date(
                from: value
            )
        else {
            return value
        }

        return date.formatted(
            .dateTime
                .weekday(.wide)
                .month(.abbreviated)
                .day()
        )
    }

    private func formatTimeRange(
        start: String?,
        end: String?
    ) -> String? {

        let startText =
            formatTime(start)

        let endText =
            formatTime(end)

        switch (
            startText,
            endText
        ) {

        case let (
            start?,
            end?
        ):

            return
                "\(start) – \(end)"

        case let (
            start?,
            nil
        ):

            return start

        default:

            return nil
        }
    }

    private func formatTime(
        _ value: String?
    ) -> String? {

        guard let value,
              !value.isEmpty
        else {
            return nil
        }

        let inputFormatter =
            DateFormatter()

        inputFormatter.dateFormat =
            "HH:mm:ss"

        guard let date =
            inputFormatter.date(
                from: value
            )
        else {
            return value
        }

        let outputFormatter =
            DateFormatter()

        outputFormatter.dateFormat =
            "h:mm a"

        return outputFormatter.string(
            from: date
        )
    }
    @ViewBuilder
    private var birthdaysContent: some View {

        if vm.isLoading {

            ProgressView()

        } else if let error =
                    vm.errorMessage {

            ContentUnavailableView(
                "Birthday Error",
                systemImage:
                    "exclamationmark.triangle",
                description:
                    Text(error)
            )

        } else if vm.birthdays.isEmpty {

            ContentUnavailableView(
                "No Birthdays",
                systemImage:
                    "birthday.cake",
                description:
                    Text(
                        "There are no birthdays in \(monthTitle)."
                    )
            )

        } else {

            List(vm.birthdays) { birthday in

                HStack(
                    alignment: .top,
                    spacing: 12
                ) {

                    familyThumbnail(
                        path:
                            birthday.familyThumbnailUrl
                    )

                    VStack(
                        alignment: .leading,
                        spacing: 5
                    ) {

                        Text(
                            birthday.displayName
                        )
                        .font(.headline)

                        Text(
                            formatMonthDay(
                                birthday.birthday
                            )
                        )
                        .font(.subheadline)
                        .foregroundStyle(
                            .secondary
                        )

                        if let phone =
                            birthday.phoneNumber,
                           !phone.isEmpty {

                            Button {
                                showPhoneOptions(phone)
                            } label: {

                                Text(
                                    formatPhone(phone)
                                )
                                .font(.subheadline)
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(.blue)
                        }
                    }
                }
                .padding(.vertical, 5)
            }
            .listStyle(.plain)
        }
    }
    @ViewBuilder
    private var anniversariesContent: some View {

        if vm.isLoading {

            ProgressView()

        } else if let error =
                    vm.errorMessage {

            ContentUnavailableView(
                "Anniversary Error",
                systemImage:
                    "exclamationmark.triangle",
                description:
                    Text(error)
            )

        } else if vm.anniversaries.isEmpty {

            ContentUnavailableView(
                "No Anniversaries",
                systemImage:
                    "heart",
                description:
                    Text(
                        "There are no anniversaries in \(monthTitle)."
                    )
            )

        } else {

            List(vm.anniversaries) { anniversary in

                HStack(
                    alignment: .top,
                    spacing: 12
                ) {

                    familyThumbnail(
                        path:
                            anniversary.familyThumbnailUrl
                    )

                    VStack(
                        alignment: .leading,
                        spacing: 5
                    ) {

                        Text(
                            anniversary.displayName
                        )
                        .font(.headline)

                        Text(
                            formatMonthDay(
                                anniversary.anniversaryDate
                            )
                        )
                        .font(.subheadline)
                        .foregroundStyle(
                            .secondary
                        )

                        HStack(spacing: 4) {

                            if let phone1 =
                                anniversary.phone1,
                               !phone1.isEmpty {

                                Button {
                                    showPhoneOptions(phone1)
                                } label: {

                                    Text(
                                        formatPhone(phone1)
                                    )
                                }
                                .buttonStyle(.plain)
                                .foregroundStyle(.blue)
                            }

                            if let phone1 =
                                anniversary.phone1,
                               !phone1.isEmpty,
                               let phone2 =
                                anniversary.phone2,
                               !phone2.isEmpty {

                                Text("and")
                                    .foregroundStyle(
                                        .secondary
                                    )
                            }

                            if let phone2 =
                                anniversary.phone2,
                               !phone2.isEmpty {

                                Button {
                                    showPhoneOptions(phone2)
                                } label: {

                                    Text(
                                        formatPhone(phone2)
                                    )
                                }
                                .buttonStyle(.plain)
                                .foregroundStyle(.blue)
                            }
                        }
                        .font(.subheadline)
                    }
                }
                .padding(.vertical, 5)
            }
            .listStyle(.plain)
        }
    }
    @ViewBuilder
    private func familyThumbnail(
        path: String?
    ) -> some View {

        if let path,
           let url = URL(
                string:
                    "\(ApiConfig.baseUrl)/\(path)"
           ) {

            AsyncImage(url: url) { phase in

                switch phase {

                case .empty:

                    ProgressView()
                        .frame(
                            width: 70,
                            height: 70
                        )

                case .success(let image):

                    image
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: 70,
                            height: 70
                        )
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 12
                            )
                        )

                case .failure:

                    thumbnailPlaceholder

                @unknown default:

                    thumbnailPlaceholder
                }
            }

        } else {

            thumbnailPlaceholder
        }
    }
    private var thumbnailPlaceholder: some View {

        ZStack {

            RoundedRectangle(
                cornerRadius: 12
            )
            .fill(
                Color(.systemGray5)
            )

            Image(
                systemName:
                    "person.2.fill"
            )
            .foregroundStyle(
                .secondary
            )
        }
        .frame(
            width: 70,
            height: 70
        )
    }
    private func formatMonthDay(
        _ value: String
    ) -> String {

        let formatter =
            DateFormatter()

        formatter.dateFormat =
            "yyyy-MM-dd"

        guard let date =
                formatter.date(
                    from: value
                )
        else {
            return value
        }

        return date.formatted(
            .dateTime
                .month(.abbreviated)
                .day()
        )
    }
    private func anniversaryPhoneText(
        phone1: String?,
        phone2: String?
    ) -> String {

        let first =
            phone1
                .map(formatPhone)

        let second =
            phone2
                .map(formatPhone)

        switch (
            first,
            second
        ) {

        case let (
            first?,
            second?
        ):

            return
                "\(first) and \(second)"

        case let (
            first?,
            nil
        ):

            return first

        case let (
            nil,
            second?
        ):

            return second

        default:

            return ""
        }
    }
    private func formatPhone(
        _ value: String
    ) -> String {

        let digits =
            value.filter {
                $0.isNumber
            }

        guard digits.count == 10
        else {
            return value
        }

        let area =
            digits.prefix(3)

        let middle =
            digits.dropFirst(3)
                .prefix(3)

        let last =
            digits.suffix(4)

        return
            "(\(area)) \(middle)-\(last)"
    }
    private func showPhoneOptions(
        _ phone: String
    ) {
        selectedPhoneNumber = phone
        showPhoneActions = true
    }
    private func callPhone(
        _ phone: String
    ) {
        let digits =
            phone.filter {
                $0.isNumber
            }

        guard let url =
            URL(
                string:
                    "tel://\(digits)"
            )
        else {
            return
        }

        UIApplication.shared.open(url)
    }
    private func textPhone(
        _ phone: String
    ) {
        let digits =
            phone.filter {
                $0.isNumber
            }

        guard let url =
            URL(
                string:
                    "sms:\(digits)"
            )
        else {
            return
        }

        UIApplication.shared.open(url)
    }


    
    
    
}

private enum MoreTab:
    String,
    CaseIterable,
    Identifiable {

    case activities
    case birthdays
    case anniversary

    var id: String {
        rawValue
    }

    var title: String {

        switch self {

        case .activities:
            return "Activities"

        case .birthdays:
            return "Birthdays"

        case .anniversary:
            return "Anniversary"
        }
    }
    
}
