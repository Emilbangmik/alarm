import SwiftUI

struct AlarmListView: View {
    @Environment(AlarmStore.self) private var store
    @State private var editingAlarm: Alarm?

    var body: some View {
        if store.alarms.isEmpty {
            VStack(spacing: 20) {
                Spacer()

                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Theme.surface)
                            .frame(width: 80, height: 80)
                        Image(systemName: "alarm")
                            .font(.system(size: 32))
                            .foregroundStyle(Theme.amber.opacity(0.6))
                    }

                    VStack(spacing: 6) {
                        Text("No alarms yet")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(Theme.textPrimary)
                        Text("Tap + to set your first alarm")
                            .font(.subheadline)
                            .foregroundStyle(Theme.textSecondary)
                    }
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
