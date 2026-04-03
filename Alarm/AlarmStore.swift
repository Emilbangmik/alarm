import SwiftUI
import AlarmKit
import ActivityKit

nonisolated struct AlarmMeta: AlarmMetadata {}

@Observable
final class AlarmStore {
    private(set) var alarms: [Alarm] = []
    var activeChallenge: Alarm?
    private let key = "savedAlarms"
    private let manager = AlarmManager.shared

    init() {
        load()
    }

    func startMonitoring() {
        Task {
            for await systemAlarms in manager.alarmUpdates {
                for systemAlarm in systemAlarms {
                    guard let localAlarm = alarms.first(where: { $0.id == systemAlarm.id }) else { continue }

                    // Challenge alarm started alerting
                    if systemAlarm.state == .alerting,
                       localAlarm.requiresTypingChallenge,
                       activeChallenge == nil {
                        activeChallenge = localAlarm
                    }

                    // Non-challenge one-time alarm finished — disable it
                    if systemAlarm.state != .alerting,
                       !localAlarm.requiresTypingChallenge,
                       localAlarm.repeatDays.isEmpty,
                       localAlarm.isEnabled {
                        disableIfOneTime(localAlarm)
                    }
                }

                // If user stopped the alarm without completing the challenge, re-fire it
                if let challenge = activeChallenge {
                    let stillAlerting = systemAlarms.contains { $0.id == challenge.id && $0.state == .alerting }
                    let stillScheduled = systemAlarms.contains { $0.id == challenge.id }
                    if !stillAlerting && !stillScheduled {
                        // Alarm was dismissed — re-schedule in 1 minute
                        rescheduleChallenge(challenge)
                    }
                }
            }
        }
    }

    private func rescheduleChallenge(_ alarm: Alarm) {
        Task {
            let date = Date().addingTimeInterval(60)
            let schedule = AlarmKit.Alarm.Schedule.fixed(date)
            let alert = AlarmPresentation.Alert(
                title: LocalizedStringResource(stringLiteral: alarm.label.isEmpty ? "Alarm" : alarm.label)
            )
            let attributes = AlarmAttributes<AlarmMeta>(
                presentation: AlarmPresentation(alert: alert),
                tintColor: Theme.amber
            )
            _ = try? await manager.schedule(
                id: alarm.id,
                configuration: AlarmManager.AlarmConfiguration(
                    schedule: schedule,
                    attributes: attributes,
                    sound: .default
                )
            )
            print("Challenge alarm re-scheduled in 1 minute")
        }
    }

    func completeChallenge() {
        guard let alarm = activeChallenge else { return }
        try? manager.cancel(id: alarm.id)
        disableIfOneTime(alarm)
        activeChallenge = nil
    }

    func failChallenge() {
        guard let alarm = activeChallenge else { return }
        activeChallenge = nil
        // Re-schedule to fire again in 1 minute
        Task {
            let date = Date().addingTimeInterval(60)
            let schedule = AlarmKit.Alarm.Schedule.fixed(date)
            let alert = AlarmPresentation.Alert(
                title: LocalizedStringResource(stringLiteral: alarm.label.isEmpty ? "Alarm" : alarm.label)
            )
            let attributes = AlarmAttributes<AlarmMeta>(
                presentation: AlarmPresentation(alert: alert),
                tintColor: Theme.amber
            )
            let countdown = AlarmKit.Alarm.CountdownDuration(
                preAlert: nil,
                postAlert: 300
            )
            _ = try? await manager.schedule(
                id: alarm.id,
                configuration: AlarmManager.AlarmConfiguration(
                    countdownDuration: countdown,
                    schedule: schedule,
                    attributes: attributes,
                    sound: .default
                )
            )
        }
    }

    func add(_ alarm: Alarm) {
        alarms.append(alarm)
        alarms.sort { ($0.hour * 60 + $0.minute) < ($1.hour * 60 + $1.minute) }
        save()
        if alarm.isEnabled {
            cancelAlarm(alarm)
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
        let current = manager.authorizationState
        print("AlarmKit auth state: \(current)")
        switch current {
        case .notDetermined:
            do {
                let state = try await manager.requestAuthorization()
                print("AlarmKit auth result: \(state)")
                return state == .authorized
            } catch {
                print("AlarmKit auth error: \(error)")
                return false
            }
        case .authorized:
            return true
        case .denied:
            print("AlarmKit auth DENIED — check Settings")
            return false
        @unknown default:
            return false
        }
    }

    // MARK: - AlarmKit Scheduling

    private func scheduleAlarm(_ alarm: Alarm) {
        Task { @MainActor in
            let title = LocalizedStringResource(stringLiteral: alarm.label.isEmpty ? "Alarm" : alarm.label)
            let alert = AlarmPresentation.Alert(title: title)

            let attributes = AlarmAttributes<AlarmMeta>(
                presentation: AlarmPresentation(alert: alert),
                tintColor: Theme.amber
            )

            // Challenge alarms: stop slider opens the app
            let stop: StopAlarmIntent? = alarm.requiresTypingChallenge ? StopAlarmIntent() : nil

            do {
                if alarm.repeatDays.isEmpty {
                    let date = nextOccurrence(hour: alarm.hour, minute: alarm.minute)
                    let schedule = AlarmKit.Alarm.Schedule.fixed(date)
                    _ = try await manager.schedule(
                        id: alarm.id,
                        configuration: .alarm(
                            schedule: schedule,
                            attributes: attributes,
                            stopIntent: stop,
                            secondaryIntent: nil,
                            sound: .default
                        )
                    )
                } else {
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
                    let schedule = AlarmKit.Alarm.Schedule.relative(.init(
                        time: time,
                        repeats: .weekly(weekdays)
                    ))
                    _ = try await manager.schedule(
                        id: alarm.id,
                        configuration: .alarm(
                            schedule: schedule,
                            attributes: attributes,
                            stopIntent: stop,
                            secondaryIntent: nil,
                            sound: .default
                        )
                    )
                }
            } catch {
                print("Failed to schedule alarm: \(error) — hour:\(alarm.hour) min:\(alarm.minute) repeat:\(alarm.repeatDays)")
            }
        }
    }

    private func disableIfOneTime(_ alarm: Alarm) {
        guard alarm.repeatDays.isEmpty,
              let index = alarms.firstIndex(where: { $0.id == alarm.id })
        else { return }
        alarms[index].isEnabled = false
        save()
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
