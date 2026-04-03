import UIKit

@Observable
final class HapticManager {
    private let light = UIImpactFeedbackGenerator(style: .light)
    private let medium = UIImpactFeedbackGenerator(style: .medium)

    func prepare() {
        light.prepare()
        medium.prepare()
    }

    func tick() {
        light.impactOccurred()
        light.prepare()
    }

    func confirm() {
        medium.impactOccurred()
    }
}
