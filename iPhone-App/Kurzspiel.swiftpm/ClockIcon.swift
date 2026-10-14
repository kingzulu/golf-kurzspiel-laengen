import SwiftUI

/// Kleines Zifferblatt, dessen Zeiger die Ausholposition zeigt.
struct ClockIcon: View {
    let swing: Swing
    var size: CGFloat = 24

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.secondary, lineWidth: 2)
            Capsule()
                .fill(Color.accentColor)
                .frame(width: 2.5, height: size * 0.38)
                .offset(y: -size * 0.19)
                .rotationEffect(.degrees(swing.degrees))
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}
