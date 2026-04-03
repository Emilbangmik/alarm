import SwiftUI

struct AlarmRowView: View {
    let alarm: Alarm
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(alarm.timeString)
                    .font(Theme.roboto(32))
                    .foregroundStyle(alarm.isEnabled ? Theme.textPrimary : Theme.textSecondary)

                if !alarm.label.isEmpty || !alarm.repeatDays.isEmpty {
                    HStack(spacing: 6) {
                        if !alarm.label.isEmpty {
                            Text(alarm.label)
                                .font(.subheadline)
                                .foregroundStyle(Theme.textSecondary)
                        }
                        if !alarm.label.isEmpty && !alarm.repeatDays.isEmpty {
                            Text("·")
                                .foregroundStyle(Theme.textSecondary)
                        }
                        if !alarm.repeatSummary.isEmpty {
                            Text(alarm.repeatSummary)
                                .font(.caption)
                                .foregroundStyle(alarm.isEnabled ? Theme.amber.opacity(0.7) : Theme.textSecondary)
                        }
                    }
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
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    VStack(spacing: 8) {
        AlarmRowView(
            alarm: Alarm(hour: 7, minute: 30, label: "Morning", repeatDays: [.monday, .tuesday, .wednesday, .thursday, .friday]),
            onToggle: {}
        )
        AlarmRowView(
            alarm: Alarm(hour: 22, minute: 0, isEnabled: false, label: "Bedtime"),
            onToggle: {}
        )
    }
    .padding()
    .background(.black)
}
