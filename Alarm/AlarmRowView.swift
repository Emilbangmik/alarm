import SwiftUI

struct AlarmRowView: View {
    let alarm: Alarm
    let onToggle: () -> Void

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

                // Label and repeat
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

                Spacer()

                Toggle("", isOn: Binding(
                    get: { alarm.isEnabled },
                    set: { _ in onToggle() }
                ))
                .labelsHidden()
                .tint(Theme.amber)
            }
            .padding(.leading, 12)
            .padding(.trailing, 14)
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
        AlarmRowView(
            alarm: Alarm(hour: 5, minute: 20, label: "", repeatDays: [.friday]),
            onToggle: {}
        )
        .listRowBackground(Theme.surface)
    }
    .listStyle(.plain)
    .scrollContentBackground(.hidden)
    .background(.black)
}
