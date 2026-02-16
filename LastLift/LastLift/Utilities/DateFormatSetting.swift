import Foundation

/// User preference for how dates are displayed on the dashboard
enum DateFormatSetting: String, CaseIterable {
    case relative
    case absolute
    case daysOnly

    var label: String {
        switch self {
        case .relative: "Relative (2 weeks ago)"
        case .absolute: "Absolute (Jan 2, 2026)"
        case .daysOnly: "Days only (12 days)"
        }
    }

    /// Formats a date according to this setting
    func format(_ date: Date) -> String {
        switch self {
        case .relative:
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .full
            return formatter.localizedString(for: date, relativeTo: .now)
        case .absolute:
            return date.formatted(.dateTime.month(.abbreviated).day().year())
        case .daysOnly:
            let days = Calendar.current.dateComponents([.day], from: date, to: .now).day ?? 0
            return days == 0 ? "Today" : "\(days) days"
        }
    }
}
