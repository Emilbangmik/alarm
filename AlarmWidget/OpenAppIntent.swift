import AppIntents

struct OpenAppIntent: AppIntent {
    static let title: LocalizedStringResource = "Open Slap"
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        .result()
    }
}
