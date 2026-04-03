import SwiftUI

enum AlarmEditMode {
    case add
    case edit(Alarm)
}

struct AlarmEditView: View {
    @Environment(AlarmStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    let mode: AlarmEditMode

    @State private var hour: Int
    @State private var minute: Int
    @State private var label: String
    @State private var repeatDays: Set<Weekday>
    @State private var requiresTypingChallenge: Bool

    private let haptics = HapticManager()

    init(mode: AlarmEditMode) {
        self.mode = mode
        switch mode {
        case .add:
            let components = Calendar.current.dateComponents([.hour, .minute], from: Date())
            _hour = State(initialValue: components.hour ?? 7)
            _minute = State(initialValue: components.minute ?? 0)
            _label = State(initialValue: "")
            _repeatDays = State(initialValue: [])
            _requiresTypingChallenge = State(initialValue: false)
        case .edit(let alarm):
            _hour = State(initialValue: alarm.hour)
            _minute = State(initialValue: alarm.minute)
            _label = State(initialValue: alarm.label)
            _repeatDays = State(initialValue: alarm.repeatDays)
            _requiresTypingChallenge = State(initialValue: alarm.requiresTypingChallenge)
        }
    }

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Time picker
                    SplitFlapTimePicker(hour: $hour, minute: $minute)

                    // Label
                    TextField("Label", text: $label)
                        .textFieldStyle(.plain)
                        .foregroundStyle(Theme.textPrimary)
                        .padding()
                        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 12))

                    // Repeat days
                    VStack(alignment: .leading, spacing: 10) {
                        Text("REPEAT")
                            .font(.caption)
                            .foregroundStyle(Theme.textSecondary)
                            .tracking(1)
                        WeekdayPicker(selection: $repeatDays)
                    }

                    // Type to dismiss
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle(isOn: $requiresTypingChallenge) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Type to dismiss")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(Theme.textPrimary)
                                Text("Type a sentence to turn off the alarm")
                                    .font(.caption)
                                    .foregroundStyle(Theme.textSecondary)
                            }
                        }
                        .tint(Theme.amber)
                    }
                    .padding(14)
                    .background(Theme.surface, in: RoundedRectangle(cornerRadius: 12))

                    // Delete button (edit mode only)
                    if isEditing {
                        Button(role: .destructive) {
                            if case .edit(let alarm) = mode {
                                store.delete(alarm)
                                dismiss()
                            }
                        } label: {
                            Text("Delete Alarm")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.red.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))
                        }
                        .foregroundStyle(.red)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
            }
            .background(Theme.background)
            .navigationTitle(isEditing ? "Edit Alarm" : "New Alarm")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Theme.textSecondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveAlarm()
                        haptics.confirm()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(Theme.amber)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(Theme.background)
    }

    private func saveAlarm() {
        switch mode {
        case .add:
            let alarm = Alarm(
                hour: hour,
                minute: minute,
                label: label,
                repeatDays: repeatDays,
                requiresTypingChallenge: requiresTypingChallenge
            )
            store.add(alarm)
        case .edit(let existing):
            var updated = existing
            updated.hour = hour
            updated.minute = minute
            updated.label = label
            updated.repeatDays = repeatDays
            updated.requiresTypingChallenge = requiresTypingChallenge
            store.update(updated)
        }
    }
}

#Preview {
    AlarmEditView(mode: .add)
        .environment(AlarmStore())
}
