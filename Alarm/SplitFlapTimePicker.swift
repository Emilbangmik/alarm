import SwiftUI

struct SplitFlapTimePicker: View {
    @Binding var hour: Int
    @Binding var minute: Int

    @State private var hourDrag: CGFloat = 0
    @State private var minuteDrag: CGFloat = 0
    @State private var flipDirection: FlipDirection = .down
    @State private var flipSpeed: CGFloat = 0

    private let haptics = HapticManager()
    private let stepSize: CGFloat = 20

    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 6) {
                // Hour digits
                digitPair(
                    value: $hour,
                    range: 24,
                    dragAccumulator: $hourDrag
                )

                // Colon
                VStack(spacing: 14) {
                    Circle()
                        .fill(Theme.amber.opacity(0.8))
                        .frame(width: 8, height: 8)
                    Circle()
                        .fill(Theme.amber.opacity(0.8))
                        .frame(width: 8, height: 8)
                }
                .frame(width: 20, height: 68)

                // Minute digits
                digitPair(
                    value: $minute,
                    range: 60,
                    dragAccumulator: $minuteDrag
                )
            }

        }
        .environment(\.flipDirection, flipDirection)
        .environment(\.flipSpeed, flipSpeed)
        .onAppear {
            haptics.prepare()
        }
    }

    @ViewBuilder
    private func digitPair(
        value: Binding<Int>,
        range: Int,
        dragAccumulator: Binding<CGFloat>
    ) -> some View {
        VStack(spacing: 6) {
            // Up chevron
            Image(systemName: "chevron.up")
                .font(.caption)
                .foregroundStyle(Theme.amber.opacity(0.3))

            // Digits
            HStack(spacing: 3) {
                SplitFlapDigit(value: value.wrappedValue / 10, size: .medium)
                SplitFlapDigit(value: value.wrappedValue % 10, size: .medium)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 5)
                    .onChanged { gesture in
                        let delta = gesture.translation.height - dragAccumulator.wrappedValue
                        let steps = Int(delta / stepSize)
                        if steps != 0 {
                            dragAccumulator.wrappedValue += CGFloat(steps) * stepSize
                            flipDirection = steps > 0 ? .down : .up
                            flipSpeed = abs(gesture.velocity.height)
                            let newValue = (value.wrappedValue - steps + range * 100) % range
                            value.wrappedValue = newValue
                            haptics.tick()
                        }
                    }
                    .onEnded { _ in
                        dragAccumulator.wrappedValue = 0
                        flipSpeed = 0
                    }
            )

            // Down chevron
            Image(systemName: "chevron.down")
                .font(.caption)
                .foregroundStyle(Theme.amber.opacity(0.3))
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var hour = 7
        @State var minute = 30
        var body: some View {
            SplitFlapTimePicker(hour: $hour, minute: $minute)
                .padding()
                .background(.black)
        }
    }
    return PreviewWrapper()
}
