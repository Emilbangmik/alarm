import SwiftUI

struct AlarmListView: View {
    @Environment(AlarmStore.self) private var store
    @State private var editingAlarm: Alarm?

    var body: some View {
        if store.alarms.isEmpty {
            VStack(spacing: 12) {
                Image(systemName: "alarm")
                    .font(.system(size: 40))
                    .foregroundStyle(Theme.textSecondary)
                Text("No alarms")
                    .font(.headline)
                    .foregroundStyle(Theme.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 60)
        } else {
            VStack(spacing: 8) {
                ForEach(store.alarms) { alarm in
                    AlarmRowView(alarm: alarm) {
                        store.toggle(alarm)
                    }
                    .onTapGesture {
                        editingAlarm = alarm
                    }
                }
            }
            .sheet(item: $editingAlarm) { alarm in
                AlarmEditView(mode: .edit(alarm))
            }
        }
    }
}
