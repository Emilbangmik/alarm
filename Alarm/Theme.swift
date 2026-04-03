import SwiftUI

enum Theme {
    static let background = Color.black
    static let surface = Color(red: 26 / 255, green: 26 / 255, blue: 26 / 255)
    static let amber = Color(red: 1, green: 149 / 255, blue: 0)
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.5)
    static let divider = Color.white.opacity(0.1)

    static func roboto(_ size: CGFloat) -> Font {
        .custom("RobotoCondensed-Bold", size: size)
    }
}
