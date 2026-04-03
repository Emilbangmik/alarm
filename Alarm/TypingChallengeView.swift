import SwiftUI

struct TypingChallengeView: View {
    let alarm: Alarm
    let onComplete: () -> Void

    @State private var input = ""
    @State private var completed = false
    @FocusState private var focused: Bool

    private let haptics = HapticManager()
    @State private var soundPlayer = AlarmSoundPlayer()

    private static let phrases = [
        "I am awake and ready to start my day",
        "The morning sun brings new energy",
        "Rise and shine the world is waiting",
        "Every great day starts with getting up",
        "Today is full of possibility",
        "Time to make today count",
        "A new day a fresh beginning",
        "Good things come to those who wake up",
    ]

    @State private var phrase: String = ""

    private var progress: Double {
        guard !phrase.isEmpty else { return 0 }
        let matched = zip(input.lowercased(), phrase.lowercased())
            .prefix(while: { $0 == $1 })
            .count
        return Double(matched) / Double(phrase.count)
    }

    private var isCorrect: Bool {
        input.lowercased() == phrase.lowercased()
    }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "alarm.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(Theme.amber)

                    Text(alarm.label.isEmpty ? "Alarm" : alarm.label)
                        .font(.title3.weight(.medium))
                        .foregroundStyle(Theme.textPrimary)

                    Text(alarm.timeString)
                        .font(Theme.roboto(24))
                        .foregroundStyle(Theme.textSecondary)
                }
                .padding(.top, 60)

                Spacer()

                // Challenge section
                VStack(spacing: 24) {
                    Text("TYPE TO DISMISS")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Theme.amber)
                        .tracking(2)

                    // Phrase to type
                    Text(phrase)
                        .font(.title3.weight(.medium))
                        .foregroundStyle(Theme.textPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)

                    // Progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Theme.surface)
                                .frame(height: 4)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Theme.amber)
                                .frame(width: geo.size.width * progress, height: 4)
                                .animation(.easeOut(duration: 0.15), value: progress)
                        }
                    }
                    .frame(height: 4)
                    .padding(.horizontal, 32)

                    // Text input
                    TextField("Start typing...", text: $input)
                        .textFieldStyle(.plain)
                        .font(.body)
                        .foregroundStyle(Theme.textPrimary)
                        .tint(Theme.amber)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal, 24)
                        .focused($focused)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .onChange(of: input) { _, _ in
                            if isCorrect && !completed {
                                completed = true
                                soundPlayer.stopPlaying()
                                haptics.confirm()
                                Task {
                                    try? await Task.sleep(for: .seconds(0.5))
                                    onComplete()
                                }
                            }
                        }
                }

                Spacer()

                // Completion state
                if completed {
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(Theme.amber)
                        Text("Alarm dismissed")
                            .font(.subheadline)
                            .foregroundStyle(Theme.textSecondary)
                    }
                    .transition(.opacity.combined(with: .scale))
                    .padding(.bottom, 60)
                }
            }
        }
        .interactiveDismissDisabled()
        .onAppear {
            phrase = Self.phrases.randomElement() ?? Self.phrases[0]
            haptics.prepare()
            soundPlayer.startPlaying()
            focused = true
        }
    }
}

#Preview {
    TypingChallengeView(
        alarm: Alarm(hour: 7, minute: 30, label: "Morning"),
        onComplete: {}
    )
}
