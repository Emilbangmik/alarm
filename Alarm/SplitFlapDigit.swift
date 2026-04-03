import SwiftUI

// MARK: - Size Presets

enum SplitFlapSize {
    case large
    case medium

    var width: CGFloat {
        switch self {
        case .large: 115
        case .medium: 80
        }
    }

    var fullHeight: CGFloat {
        switch self {
        case .large: 98
        case .medium: 68
        }
    }

    var fontSize: CGFloat {
        switch self {
        case .large: 90
        case .medium: 62
        }
    }

    var cornerRadius: CGFloat {
        switch self {
        case .large: 16
        case .medium: 12
        }
    }

    var gap: CGFloat {
        switch self {
        case .large: 2
        case .medium: 2
        }
    }

    var halfHeight: CGFloat { (fullHeight - gap) / 2 }
}

// MARK: - Single Flap Half

struct FlapHalf: View {
    let text: String
    let isTop: Bool
    let width: CGFloat
    let halfHeight: CGFloat
    let fullHeight: CGFloat
    let fontSize: CGFloat
    let cornerRadius: CGFloat

    private let bgColor = Color(red: 26 / 255, green: 26 / 255, blue: 26 / 255)

    private var shape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(
            topLeadingRadius: isTop ? cornerRadius : 0,
            bottomLeadingRadius: isTop ? 0 : cornerRadius,
            bottomTrailingRadius: isTop ? 0 : cornerRadius,
            topTrailingRadius: isTop ? cornerRadius : 0
        )
    }

    var body: some View {
        ZStack {
            bgColor

            Text(text)
                .font(.custom("RobotoCondensed-Bold", size: fontSize))
                .foregroundStyle(.white)
                .frame(width: width, height: fullHeight)
                .frame(width: width, height: halfHeight, alignment: isTop ? .top : .bottom)
                .clipped()
        }
        .frame(width: width, height: halfHeight)
        .clipShape(shape)
        .overlay {
            shape
                .inset(by: 0.5)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                .blur(radius: 0.5)
                .offset(x: 0.5, y: 0.5)
                .clipShape(shape)
        }
    }
}

// MARK: - Split Flap Digit

struct SplitFlapDigit: View {
    let value: Int
    let size: SplitFlapSize

    @State private var previousValue: Int
    @State private var animating = false
    @State private var showingFront = true
    @State private var showOldBottom = false
    @State private var topAngle: Double = 0

    private var width: CGFloat { size.width }
    private var fullHeight: CGFloat { size.fullHeight }
    private var fontSize: CGFloat { size.fontSize }
    private var cornerRadius: CGFloat { size.cornerRadius }
    private var gap: CGFloat { size.gap }
    private var halfHeight: CGFloat { size.halfHeight }

    init(value: Int, size: SplitFlapSize = .large) {
        self.value = value
        self.size = size
        self._previousValue = State(initialValue: value)
    }

    private func makeHalf(_ text: String, isTop: Bool) -> FlapHalf {
        FlapHalf(
            text: text,
            isTop: isTop,
            width: width,
            halfHeight: halfHeight,
            fullHeight: fullHeight,
            fontSize: fontSize,
            cornerRadius: cornerRadius
        )
    }

    var body: some View {
        ZStack {
            // Static base: new digit
            VStack(spacing: gap) {
                makeHalf("\(value)", isTop: true)
                makeHalf(showOldBottom ? "\(previousValue)" : "\(value)", isTop: false)
            }

            if animating {
                // Single flap: front face (old top) → back face (new bottom)
                VStack(spacing: gap) {
                    Group {
                        if showingFront {
                            makeHalf("\(previousValue)", isTop: true)
                        } else {
                            makeHalf("\(value)", isTop: false)
                                .scaleEffect(y: -1)
                        }
                    }
                    .rotation3DEffect(
                        .degrees(topAngle),
                        axis: (1, 0, 0),
                        anchor: UnitPoint(x: 0.5, y: 1 + gap / (2 * halfHeight)),
                        perspective: 0.4
                    )
                    .zIndex(1)
                    Color.clear.frame(width: width, height: halfHeight)
                }
            }
        }
        .frame(width: width, height: fullHeight)
        .onChange(of: value) { oldVal, newVal in
            guard oldVal != newVal else { return }
            previousValue = oldVal
            animating = true
            showingFront = true
            showOldBottom = true
            topAngle = 0

            // Phase 1: front face falls (0° → -90°)
            withAnimation(.easeIn(duration: 0.25)) {
                topAngle = -90
            }

            // Phase 2: swap face at midpoint, continue (-90° → -180°)
            Task {
                try? await Task.sleep(for: .seconds(0.25))
                showingFront = false
                withAnimation(.easeOut(duration: 0.25)) {
                    topAngle = -180
                }
                // Switch static bottom to new digit while flap covers it
                try? await Task.sleep(for: .seconds(0.2))
                showOldBottom = false
                // Remove flap after it has fully landed
                try? await Task.sleep(for: .seconds(0.05))
                animating = false
                showingFront = true
            }
        }
    }
}

#Preview {
    HStack(spacing: 4) {
        SplitFlapDigit(value: 2)
        SplitFlapDigit(value: 4)
    }
    .padding()
    .background(.black)
}
