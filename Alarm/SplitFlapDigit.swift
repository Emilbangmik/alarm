import SwiftUI

// MARK: - Flip Direction

enum FlipDirection {
    case up, down
}

private struct FlipDirectionKey: EnvironmentKey {
    static let defaultValue: FlipDirection = .down
}

extension EnvironmentValues {
    var flipDirection: FlipDirection {
        get { self[FlipDirectionKey.self] }
        set { self[FlipDirectionKey.self] = newValue }
    }
}

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

    @Environment(\.flipDirection) private var flipDirection
    @State private var previousValue: Int
    @State private var animating = false
    @State private var showingFront = true
    @State private var showOldStatic = false
    @State private var flapAngle: Double = 0
    @State private var currentDirection: FlipDirection = .down

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
            // Static base
            VStack(spacing: gap) {
                if currentDirection == .up && animating {
                    makeHalf(showOldStatic ? "\(previousValue)" : "\(value)", isTop: true)
                } else {
                    makeHalf("\(value)", isTop: true)
                }

                if currentDirection == .down && animating {
                    makeHalf(showOldStatic ? "\(previousValue)" : "\(value)", isTop: false)
                } else {
                    makeHalf("\(value)", isTop: false)
                }
            }

            if animating {
                if currentDirection == .down {
                    // TOP flap falls DOWN
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
                            .degrees(flapAngle),
                            axis: (1, 0, 0),
                            anchor: UnitPoint(x: 0.5, y: 1 + gap / (2 * halfHeight)),
                            perspective: 0.4
                        )
                        .zIndex(1)
                        Color.clear.frame(width: width, height: halfHeight)
                    }
                } else {
                    // BOTTOM flap flips UP
                    VStack(spacing: gap) {
                        Color.clear.frame(width: width, height: halfHeight)
                        Group {
                            if showingFront {
                                makeHalf("\(previousValue)", isTop: false)
                            } else {
                                makeHalf("\(value)", isTop: true)
                                    .scaleEffect(y: -1)
                            }
                        }
                        .rotation3DEffect(
                            .degrees(flapAngle),
                            axis: (1, 0, 0),
                            anchor: UnitPoint(x: 0.5, y: -gap / (2 * halfHeight)),
                            perspective: 0.4
                        )
                        .zIndex(1)
                    }
                }
            }
        }
        .frame(width: width, height: fullHeight)
        .onChange(of: value) { oldVal, newVal in
            guard oldVal != newVal else { return }
            previousValue = oldVal
            currentDirection = flipDirection
            animating = true
            showingFront = true
            showOldStatic = true
            flapAngle = 0

            let phase1Target: Double = currentDirection == .down ? -90 : 90
            let phase2Target: Double = currentDirection == .down ? -180 : 180

            withAnimation(.easeIn(duration: 0.25)) {
                flapAngle = phase1Target
            }

            Task {
                try? await Task.sleep(for: .seconds(0.25))
                showingFront = false
                withAnimation(.easeOut(duration: 0.25)) {
                    flapAngle = phase2Target
                }
                try? await Task.sleep(for: .seconds(0.2))
                showOldStatic = false
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
