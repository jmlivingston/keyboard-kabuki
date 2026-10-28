// PROTOTYPE, throwaway (branch prototype/language-tint-screen, never merge).
// A static drawing of the French Kabuki Keyboard in its Language Tint, using the inset-card
// treatment chosen in "How does a Language Tint look inside the iOS 26 keyboard frame?".

import SwiftUI

struct PrototypeKeyboardPreview: View {
    let tint: Color
    var compact = false

    @Environment(\.colorScheme) private var colorScheme

    private let rows: [[String]] = [
        ["A", "Z", "E", "R", "T", "Y", "U", "I", "O", "P"],
        ["Q", "S", "D", "F", "G", "H", "J", "K", "L", "M"],
        ["⇧", "W", "X", "C", "V", "B", "N", "´", "⌫"],
        ["123", "espace", "⏎"],
    ]

    var body: some View {
        VStack(spacing: compact ? 4 : 8) {
            ForEach(rows.indices, id: \.self) { r in
                HStack(spacing: compact ? 3 : 5) {
                    ForEach(rows[r], id: \.self) { label in
                        Text(label)
                            .font(.system(size: compact ? 9 : 16))
                            .frame(maxWidth: label == "espace" ? .infinity : nil)
                            .frame(minWidth: compact ? 12 : 24, maxWidth: label == "espace" ? .infinity : 40)
                            .frame(height: compact ? 18 : 36)
                            .background(keyColor, in: RoundedRectangle(cornerRadius: compact ? 3 : 5))
                    }
                }
            }
        }
        .padding(compact ? 6 : 10)
        .background(tint, in: RoundedRectangle(cornerRadius: compact ? 10 : 20))
        .padding(compact ? 4 : 6)
        // The iOS 26 frame: grey band and globe/mic strip that the tint can't cover.
        .padding(.bottom, compact ? 14 : 34)
        .overlay(alignment: .bottom) {
            HStack {
                Image(systemName: "globe")
                Spacer()
                Image(systemName: "mic")
            }
            .font(compact ? .caption2 : .body)
            .padding(.horizontal, compact ? 10 : 18)
            .padding(.bottom, compact ? 3 : 8)
        }
        .background(frameColor, in: RoundedRectangle(cornerRadius: compact ? 14 : 28))
    }

    private var keyColor: Color { colorScheme == .dark ? Color(white: 0.42) : .white }
    private var frameColor: Color { colorScheme == .dark ? Color(white: 0.1) : Color(white: 0.89) }
}
