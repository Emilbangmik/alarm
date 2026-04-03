import SwiftUI

struct SplitFlapClock: View {
    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let components = Calendar.current.dateComponents(
                [.hour, .minute, .second],
                from: context.date
            )
            let h = components.hour ?? 0
            let m = components.minute ?? 0
            let s = components.second ?? 0

            GeometryReader { geo in
                let isLandscape = geo.size.width > geo.size.height
                let idealWidth: CGFloat = isLandscape
                    ? 6 * 115 + 2 * 24 + 5 * 4 + 2 * 8
                    : 4 * 115 + 1 * 24 + 3 * 4 + 2 * 8
                let scale = min(1, (geo.size.width - 32) / idealWidth)

                HStack(spacing: 8) {
                    HStack(spacing: 4) {
                        SplitFlapDigit(value: h / 10)
                        SplitFlapDigit(value: h % 10)
                    }

                    ColonSeparator()

                    HStack(spacing: 4) {
                        SplitFlapDigit(value: m / 10)
                        SplitFlapDigit(value: m % 10)
                    }

                    if isLandscape {
                        ColonSeparator()

                        HStack(spacing: 4) {
                            SplitFlapDigit(value: s / 10)
                            SplitFlapDigit(value: s % 10)
                        }
                    }
                }
                .fixedSize()
                .scaleEffect(scale)
                .position(x: geo.size.width / 2, y: geo.size.height / 2)
            }
        }
        .accessibilityElement()
        .accessibilityLabel("Clock")
    }
}

struct ColonSeparator: View {
    var body: some View {
        VStack(spacing: 20) {
            Circle()
                .fill(.white.opacity(0.7))
                .frame(width: 10, height: 10)
            Circle()
                .fill(.white.opacity(0.7))
                .frame(width: 10, height: 10)
        }
        .frame(width: 24, height: 98)
    }
}

#Preview {
    SplitFlapClock()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black)
        .preferredColorScheme(.dark)
}
