import SwiftUI

struct WeekdayPicker: View {
    @Binding var selection: Set<Weekday>

    private let haptics = HapticManager()
    private let orderedDays: [Weekday] = [
        .monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday
    ]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(orderedDays) { day in
                let isSelected = selection.contains(day)
                Button {
                    if isSelected {
                        selection.remove(day)
                    } else {
                        selection.insert(day)
                    }
                    haptics.tick()
                } label: {
                    Text(day.singleLetter)
                        .font(Theme.roboto(14))
                        .frame(width: 40, height: 40)
                        .foregroundStyle(isSelected ? .black : Theme.textSecondary)
                        .background(isSelected ? Theme.amber : Theme.surface)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
        }
        .onAppear { haptics.prepare() }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var days: Set<Weekday> = [.monday, .wednesday, .friday]
        var body: some View {
            WeekdayPicker(selection: $days)
                .padding()
                .background(.black)
        }
    }
    return PreviewWrapper()
}
