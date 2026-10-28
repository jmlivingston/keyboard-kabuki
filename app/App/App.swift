import SwiftUI

@main
struct HelloApp: App {
    var body: some Scene {
        WindowGroup {
            // PROTOTYPE (branch prototype/language-tint-screen): Language Tint screen variants.
            PrototypeLanguageTintRoot()
        }
    }
}

struct PrototypeLanguageTintRoot: View {
    @State private var variant = UserDefaults.standard.string(forKey: "variant") ?? "A"
    @State private var tint = prototypeDefaultTint

    var body: some View {
        ZStack(alignment: .bottom) {
            switch variant {
            case "B": VariantB(tint: $tint)
            case "C": VariantC(tint: $tint)
            default: VariantA(tint: $tint)
            }
            #if DEBUG
            PrototypeSwitcher(
                current: $variant,
                variants: [("A", "List → detail"), ("B", "Preview first"), ("C", "Tap the keyboard")],
                tint: tint
            )
            .padding(.bottom, 8)
            #endif
        }
    }
}
