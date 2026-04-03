import SwiftUI
import AlarmKit
import ActivityKit

nonisolated struct AlarmMeta: AlarmMetadata {}

@Observable
final class AlarmStore {
    private(set) var alarms: [Alarm] = []
    private let key = "savedAlarms"
    private let manager = AlarmManager.shared

    init() {
        load()
    }

    func add(_ alarm: Alarm) {
        alarms.append(alarm)
        alarms.sort { ($0.hour * 60 + $0.minute) < ($1.hour * 60 + $1.minute) }
        save()
        if alarm.isEnabled {
            scheduleAlarm(alarm)
        }
    }

    func update(_ alarm: Alarm) {
        guard let index = alarms.firstIndex(where: { $0.id == alarm.id }) else { return }
        alarms[index] = alarm
        alarms.sort { ($0.hour * 60 + $0.minute) < ($1.hour * 60 + $1.minute) }
        save()
        cancelAlarm(alarm)
        if alarm.isEnabled {
            scheduleAlarm(alarm)
        }
    }

    func toggle(_ alarm: Alarm) {
        guard let index = alarms.firstIndex(where: { $0.id == alarm.id }) else { return }
        alarms[index].isEnabled.toggle()
        save()
        if alarms[index].isEnabled {
            scheduleAlarm(alarms[index])
        } else {
            cancelAlarm(alarms[index])
        }
    }

    func delete(_ alarm: Alarm) {
        cancelAlarm(alarm)
        alarms.removeAll { $0.id == alarm.id }
        save()
    }

    func deleteAtOffsets(_ offsets: IndexSet) {
        for index in offsets {
            cancelAlarm(alarms[index])
        }
        alarms.remove(atOffsets: offsets)
        save()
    }

    func requestAuthorization() async -> Bool {
        switch manager.authorizationState {
        case .notDetermined:
            do {
                let state = try await manager.requestAuthorization()
                return state == .authorized
            } catch {
                return false
            }
        case .authorized:
            return true
        case .denied:
            return false
        @unknown default:
            return false
        }
    }

    // MARK: - AlarmKit Scheduling

    private func scheduleAlarm(_ alarm: Alarm) {
        Task {
            let alert = AlarmPresentation.Alert(
                title: LocalizedStringResource(stringLiteral: alarm.label.isEmpty ? "Alarm" : alarm.label)
            )

            let attributes = AlarmAttributes<AlarmMeta>(
                presentation: AlarmPresentation(alert: alert),
                tintColor: Theme.amber
            )

            do {
                if alarm.repeatDays.isEmpty {
                    // One-time alarm
                    let date = nextOccurrence(hour: alarm.hour, minute: alarm.minute)
                    let schedule = AlarmKit.Alarm.Schedule.fixed(date)
                    _ = try await manager.schedule(
                        id: alarm.id,
                        configuration: AlarmManager.AlarmConfiguration(
                            schedule: schedule,
                            attributes: attributes,
                            sound: .default
                        )
                    )
                } else {
                    // Recurring alarm
                    let time = AlarmKit.Alarm.Schedule.Relative.Time(
                        hour: alarm.hour,
                        minute: alarm.minute
                    )
                    let weekdays: [Locale.Weekday] = alarm.repeatDays.map { weekday in
                        switch weekday {
                        case .sunday: .sunday
                        case .monday: .monday
                        case .tuesday: .tuesday
                        case .wednesday: .wednesday
                        case .thursday: .thursday
                        case .friday: .friday
                        case .saturday: .saturday
                        }
                    }
                    let relative = AlarmKit.Alarm.Schedule.Relative(
                        time: time,
                        repeats: .weekly(weekdays)
                    )
                    let schedule = AlarmKit.Alarm.Schedule.relative(relative)
                    _ = try await manager.schedule(
                        id: alarm.id,
                        configuration: AlarmManager.AlarmConfiguration(
                            schedule: schedule,
                            attributes: attributes,
                            sound: .default
                        )
                    )
                }
            } catch {
                print("Failed to schedule alarm: \(error)")
            }
        }
    }

    private func cancelAlarm(_ alarm: Alarm) {
        try? manager.cancel(id: alarm.id)
    }

    private func nextOccurrence(hour: Int, minute: Int) -> Date {
        let now = Date()
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = hour
        components.minute = minute
        components.second = 0
        if let date = calendar.date(from: components), date > now {
            return date
        }
        return calendar.date(byAdding: .day, value: 1, to: calendar.date(from: components)!)!
    }

    // MARK: - Persistence

    private func save() {
        if let data = try? JSONEncoder().encode(alarms) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([Alarm].self, from: data)
        else { return }
        alarms = decoded
    }
}
