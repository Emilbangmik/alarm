import SwiftUI

struct TypingChallengeView: View {
    let alarm: Alarm
    let onComplete: () -> Void
    var playSound: Bool = true

    @State private var input = ""
    @State private var completed = false
    @State private var isFiltering = false
    @State private var showError = false
    @FocusState private var focused: Bool

    private let haptics = HapticManager()
    @State private var soundPlayer = AlarmSoundPlayer()

    private static let phrases = [
        "I am awake, alert and ready",
        "The morning sun brings new energy",
        "Rise and shine the world is waiting",
        "Every great day starts with getting up",
        "Today is full of possibility",
        "Time to make today count",
        "A new day a fresh beginning",
        "Good things come to those who wake up",
        "Today is going to be a great day",
        "I choose to rise and start my morning strong",
        "Every morning is a fresh new beginning",
        "I am awake, alert and ready to move",
        "I can do hard things even when I am tired",
        "Getting up now makes the whole day easier",
        "My future self will thank me for waking up",
        "One strong morning can change my whole week",
        "I am the kind of person who gets up on time",
        "Five minutes of discomfort beats all day regret",
        "My energy will grow once I am out of bed",
        "I only need to win this one small moment",
        "Standing up now is my first victory today",
        "I do not negotiate with the snooze button",
        "I lead my day instead of reacting to it",
        "Movement creates energy so I start by moving",
        "A clear mind starts with an early wake up",
        "I wake up once and I wake up fully",
        "I am stronger than my sleepy thoughts",
        "Getting up now protects my goals and priorities",
        "I am building a powerful morning habit today",
        "The sooner I rise, the calmer my day feels",
        "I am trading ten seconds of effort for hours of focus",
        "My body wakes up faster when I start moving",
        "I get out of bed before my excuses arrive",
        "I am awake and I am already making progress",
        "Waking up on time is an investment in myself",
        "One honest alarm is better than three snoozes",
        "I am choosing long term clarity over short term comfort",
        "I do not wait for motivation, I create it now",
        "My best ideas need me to be awake and present",
        "I show up for myself even when it is hard",
        "Morning discipline makes the rest of the day simple",
        "I breathe in energy and breathe out sleepiness",
        "Getting up now keeps my promises to myself",
        "I am building a streak I am proud of",
        "My first action today is aligned with my goals",
        "I wake up once and I stay out of bed",
        "I am capable of more than my sleepy brain thinks",
        "This small decision shapes the rest of my day",
        "I step into the day with clarity and intention",
        "I am choosing progress over the comfort of the pillow",
        "When the alarm rings, I rise, not hesitate",
        "I deserve a day that starts with self respect",
        "My energy grows with each step I take",
        "I wake up for the person I want to become",
        "I get stronger every time I beat the snooze",
        "Getting up now keeps my rhythm and my focus",
        "I am awake, I am moving, and I am in control",
        "The day has already begun and I am in it"
    ]

    @State private var phrase: String = ""

    // How many characters match from the start
    private var matchedCount: Int {
        zip(input.lowercased(), phrase.lowercased())
            .prefix(while: { $0 == $1 })
            .count
    }

    private var isCorrect: Bool {
        input.lowercased() == phrase.lowercased()
    }

    private var hasError: Bool {
        !input.isEmpty && input.count > matchedCount
    }


    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header with split flap time
                VStack(spacing: 10) {
                    HStack(spacing: 3) {
                        SplitFlapDigit(value: alarm.hour / 10, size: .medium)
                        SplitFlapDigit(value: alarm.hour % 10, size: .medium)

                        VStack(spacing: 10) {
                            Circle().fill(Theme.amber).frame(width: 6, height: 6)
                            Circle().fill(Theme.amber).frame(width: 6, height: 6)
                        }
                        .frame(width: 16)

                        SplitFlapDigit(value: alarm.minute / 10, size: .medium)
                        SplitFlapDigit(value: alarm.minute % 10, size: .medium)
                    }

                    Text(alarm.label.isEmpty ? "Alarm" : alarm.label)
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                }
                .padding(.top, 80)

                Spacer()

                // Typing test area
                VStack(spacing: 20) {
                    Text("TYPE TO DISMISS")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(Theme.amber.opacity(0.6))
                        .tracking(3)

                    // The phrase with inline coloring
                    phraseDisplay
                        .padding(.horizontal, 24)
                        .padding(.vertical, 20)
                        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal, 20)

                    // Hidden text field — input is shown inline above
                    TextField("", text: $input)
                        .focused($focused)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .opacity(0)
                        .frame(height: 1)
                        .onChange(of: input) { oldValue, newValue in
                            guard !isFiltering else { return }

                            // Only check when characters are added
                            if newValue.count > oldValue.count {
                                let matched = zip(newValue.lowercased(), phrase.lowercased())
                                    .prefix(while: { $0 == $1 })
                                    .count
                                if matched == newValue.count {
                                    // Correct character — clear error
                                    showError = false
                                } else if matched < newValue.count {
                                    // Wrong character — show red, strip silently
                                    isFiltering = true
                                    showError = true
                                    input = String(newValue.prefix(matched))
                                    Task { @MainActor in isFiltering = false }
                                    return
                                }
                            }

                            if isCorrect && !completed {
                                completed = true
                                soundPlayer.stopPlaying()
                                haptics.confirm()
                                Task {
                                    try? await Task.sleep(for: .seconds(0.6))
                                    onComplete()
                                }
                            }
                        }
                }

                Spacer()

                // Completion or hint
                if completed {
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(Theme.amber)
                        Text("Alarm dismissed")
                            .font(.subheadline)
                            .foregroundStyle(Theme.textSecondary)
                    }
                    .transition(.opacity.combined(with: .scale))
                    .padding(.bottom, 60)
                } else {
                    Text("tap anywhere to start typing")
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary.opacity(0.4))
                        .padding(.bottom, 40)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { focused = true }
        .interactiveDismissDisabled()
        .onAppear {
            phrase = Self.phrases.randomElement() ?? Self.phrases[0]
            haptics.prepare()
            if playSound { soundPlayer.startPlaying() }
            focused = true
        }
    }

    // MARK: - Phrase Display

    private var phraseDisplay: some View {
        // Build an attributed text: typed chars in green, cursor, remaining in dim
        let chars = Array(phrase)
        let inputChars = Array(input.lowercased())

        return HStack(spacing: 0) {
            Text(buildAttributedPhrase(chars: chars, inputChars: inputChars, matched: matchedCount))
                .font(.system(size: 28, weight: .medium, design: .monospaced))
                .lineSpacing(8)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func buildAttributedPhrase(chars: [Character], inputChars: [Character], matched: Int) -> AttributedString {
        var result = AttributedString()

        for (i, char) in chars.enumerated() {
            var attrChar = AttributedString(String(char))

            if i < matched {
                // Correctly typed — green
                attrChar.foregroundColor = UIColor(red: 0.35, green: 0.85, blue: 0.45, alpha: 1.0)
            } else if i == matched && showError {
                // Error at cursor position — red text, red bg only for spaces
                let errorRed = UIColor(red: 0.95, green: 0.3, blue: 0.3, alpha: 1.0)
                if char == " " {
                    attrChar.foregroundColor = .white
                    attrChar.backgroundColor = errorRed
                } else {
                    attrChar.foregroundColor = errorRed
                }
                attrChar.underlineStyle = .single
                attrChar.underlineColor = errorRed
            } else if i == matched {
                // Cursor position — show with amber underline effect
                attrChar.foregroundColor = UIColor(white: 0.95, alpha: 1.0)
                attrChar.underlineStyle = .single
                attrChar.underlineColor = UIColor(Theme.amber)
            } else {
                // Not yet typed — dim
                attrChar.foregroundColor = UIColor(white: 0.35, alpha: 1.0)
            }

            result.append(attrChar)
        }

        return result
    }
}

#Preview {
    TypingChallengeView(
        alarm: Alarm(hour: 7, minute: 30, label: "Morning"),
        onComplete: {}
    )
}
