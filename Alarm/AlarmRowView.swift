import SwiftUI

struct AlarmRowView: View {
    let alarm: Alarm
    let onToggle: () -> Void
    var onTap: (() -> Void)?

    @State private var isEnabled: Bool

    init(alarm: Alarm, onToggle: @escaping () -> Void, onTap: (() -> Void)? = nil) {
        self.alarm = alarm
        self.onToggle = onToggle
        self.onTap = onTap
        self._isEnabled = State(initialValue: alarm.isEnabled)
    }

    private var displayLabel: String {
        alarm.label.isEmpty ? "Alarm" : alarm.label
    }

    var body: some View {
        HStack(spacing: 0) {
            // Amber accent bar
            RoundedRectangle(cornerRadius: 2)
                .fill(alarm.isEnabled ? Theme.amber : Theme.amber.opacity(0.15))
                .frame(width: 3)
                .padding(.vertical, 6)

            // Tappable content area (opens edit)
            Button { onTap?() } label: {
                HStack(spacing: 16) {
                    // Mini split flap time
                    HStack(spacing: 2) {
                        SplitFlapDigit(value: alarm.hour / 10, size: .small)
                        SplitFlapDigit(value: alarm.hour % 10, size: .small)

                        VStack(spacing: 5) {
                            Circle()
                                .fill(alarm.isEnabled ? Theme.amber : Theme.textSecondary)
                                .frame(width: 4, height: 4)
                            Circle()
                                .fill(alarm.isEnabled ? Theme.amber : Theme.textSecondary)
                                .frame(width: 4, height: 4)
                        }
                        .frame(width: 12)

                        SplitFlapDigit(value: alarm.minute / 10, size: .small)
                        SplitFlapDigit(value: alarm.minute % 10, size: .small)
                    }
                    .opacity(alarm.isEnabled ? 1 : 0.35)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(displayLabel)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(alarm.isEnabled ? Theme.textPrimary : Theme.textSecondary.opacity(0.6))

                        if !alarm.repeatSummary.isEmpty {
                            Text(alarm.repeatSummary)
                                .font(.caption)
                                .foregroundStyle(alarm.isEnabled ? Theme.amber.opacity(0.7) : Theme.textSecondary.opacity(0.4))
                        }
                    }
                }
                .padding(.leading, 12)
            }
            .buttonStyle(.plain)

            Spacer()

            // Toggle — separate from the button's hit area
            Toggle("", isOn: $isEnabled)
                .labelsHidden()
                .tint(Theme.amber)
                .fixedSize()
                .padding(.trailing, 14)
                .onChange(of: isEnabled) { _, newValue in
                    if newValue != alarm.isEnabled {
                        onToggle()
                    }
                }
                .onChange(of: alarm.isEnabled) { _, newValue in
                    isEnabled = newValue
                }
        }
        .frame(height: 70)
    }
}

#Preview {
    List {
        AlarmRowView(
            alarm: Alarm(hour: 7, minute: 30, label: "Morning", repeatDays: [.monday, .tuesday, .wednesday, .thursday, .friday]),
            onToggle: {}
        )
        .listRowBackground(Theme.surface)
        AlarmRowView(
            alarm: Alarm(hour: 22, minute: 0, isEnabled: false, label: "Bedtime"),
            onToggle: {}
        )
        .listRowBackground(Theme.surface)
    }
    .listStyle(.plain)
    .scrollContentBackground(.hidden)
    .background(.black)
}
