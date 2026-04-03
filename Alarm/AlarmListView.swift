import SwiftUI

struct AlarmListView: View {
    @Environment(AlarmStore.self) private var store
    @State private var editingAlarm: Alarm?

    var body: some View {
        if store.alarms.isEmpty {
            VStack(spacing: 12) {
                Image(systemName: "alarm")
                    .font(.system(size: 40))
                    .foregroundStyle(Theme.textSecondary.opacity(0.5))
                Text("No alarms yet")
                    .font(.headline)
                    .foregroundStyle(Theme.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 60)
        } else {
            List {
                ForEach(store.alarms) { alarm in
                    AlarmRowView(alarm: alarm, onToggle: {
                        store.toggle(alarm)
                    }, onTap: {
                        editingAlarm = alarm
                    })
                    .listRowBackground(Color.clear)
                    .listRowSeparatorTint(Theme.divider)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            store.delete(alarm)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .sheet(item: $editingAlarm) { alarm in
                AlarmEditView(mode: .edit(alarm))
            }
        }
    }
}
