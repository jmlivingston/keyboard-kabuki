// PROTOTYPE, throwaway (branch prototype/language-tint-screen, never merge).
// Floating bar to flip between variants; shows the variant and the current tint so state is visible.

import SwiftUI
import UIKit

struct PrototypeSwitcher: View {
    @Binding var current: String
    let variants: [(key: String, name: String)]
    let tint: Color

    var body: some View {
        HStack(spacing: 14) {
            Button { step(-1) } label: { Image(systemName: "chevron.left") }
            VStack(spacing: 2) {
                Text("\(current) · \(variants.first { $0.key == current }?.name ?? "")").font(.caption.bold())
                Text(tintDescription).font(.caption2.monospaced())
            }
            Button { step(1) } label: { Image(systemName: "chevron.right") }
        }
        .foregroundStyle(Color(.systemBackground))
        .padding(.horizontal, 16).padding(.vertical, 8)
        .background(Color(.label).opacity(0.9), in: Capsule())
        .shadow(radius: 6)
    }

    private func step(_ delta: Int) {
        let keys = variants.map(\.key)
        let i = keys.firstIndex(of: current) ?? 0
        current = keys[(i + delta + keys.count) % keys.count]
    }

    private var tintDescription: String {
        var (r, g, b, a): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        UIColor(tint).getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "#%02X%02X%02X  α %.2f", Int(r * 255), Int(g * 255), Int(b * 255), a)
    }
}
