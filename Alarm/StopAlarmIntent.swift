import AppIntents
import AlarmKit

struct StopAlarmIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Stop Alarm"
    static var description = IntentDescription("Opens the app to complete the typing challenge")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        .result()
    }
}
