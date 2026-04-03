import Foundation

struct Alarm: Identifiable, Codable, Sendable {
    nonisolated var id: UUID
    var hour: Int
    var minute: Int
    var isEnabled: Bool
    var label: String
    var repeatDays: Set<Weekday>
    var requiresTypingChallenge: Bool

    nonisolated init(
        id: UUID = UUID(),
        hour: Int = 7,
        minute: Int = 0,
        isEnabled: Bool = true,
        label: String = "",
        repeatDays: Set<Weekday> = [],
        requiresTypingChallenge: Bool = false
    ) {
        self.id = id
        self.hour = hour
        self.minute = minute
        self.isEnabled = isEnabled
        self.label = label
        self.repeatDays = repeatDays
        self.requiresTypingChallenge = requiresTypingChallenge
    }

    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        hour = try container.decode(Int.self, forKey: .hour)
        minute = try container.decode(Int.self, forKey: .minute)
        isEnabled = try container.decode(Bool.self, forKey: .isEnabled)
        label = try container.decode(String.self, forKey: .label)
        repeatDays = try container.decode(Set<Weekday>.self, forKey: .repeatDays)
        requiresTypingChallenge = try container.decodeIfPresent(Bool.self, forKey: .requiresTypingChallenge) ?? false
    }

    nonisolated var timeString: String {
        String(format: "%02d:%02d", hour, minute)
    }

    nonisolated var repeatSummary: String {
        if repeatDays.isEmpty { return "" }
        if repeatDays.count == 7 { return "Every day" }
        let weekdays: Set<Weekday> = [.monday, .tuesday, .wednesday, .thursday, .friday]
        if repeatDays == weekdays { return "Weekdays" }
        let weekend: Set<Weekday> = [.saturday, .sunday]
        if repeatDays == weekend { return "Weekends" }
        return repeatDays.sorted { $0.rawValue < $1.rawValue }
            .map(\.shortName)
            .joined(separator: " ")
    }
}

enum Weekday: Int, Codable, CaseIterable, Identifiable, Sendable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7

    nonisolated var id: Int { rawValue }

    nonisolated var shortName: String {
        switch self {
        case .sunday: "Sun"
        case .monday: "Mon"
        case .tuesday: "Tue"
        case .wednesday: "Wed"
        case .thursday: "Thu"
        case .friday: "Fri"
        case .saturday: "Sat"
        }
    }

    nonisolated var singleLetter: String {
        switch self {
        case .sunday: "S"
        case .monday: "M"
        case .tuesday: "T"
        case .wednesday: "W"
        case .thursday: "T"
        case .friday: "F"
        case .saturday: "S"
        }
    }
}
