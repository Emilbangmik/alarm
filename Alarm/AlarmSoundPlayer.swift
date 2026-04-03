import AudioToolbox

@Observable
final class AlarmSoundPlayer {
    private var timer: Timer?

    func startPlaying() {
        // Play immediately
        AudioServicesPlayAlertSound(SystemSoundID(1005))
        // Repeat every 2 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            AudioServicesPlayAlertSound(SystemSoundID(1005))
        }
    }

    func stopPlaying() {
        timer?.invalidate()
        timer = nil
    }
}
