// PROTOTYPE host for the tint-in-frame keyboard (branch prototype/tint-in-keyboard-frame, never merge).
// Shows an auto-focused text field; the variant buttons (or `-variant B` at launch) change the field's
// return key type, which the prototype keyboard reads to pick its variant.

import SwiftUI
import UIKit

@main
struct HelloApp: App {
    var body: some Scene {
        WindowGroup {
            PrototypeHost()
        }
    }
}

struct PrototypeHost: View {
    @State private var variant = UserDefaults.standard.string(forKey: "variant") ?? "A"

    var body: some View {
        VStack(spacing: 16) {
            Text("Tint-in-frame prototype").font(.headline)
            Picker("Variant", selection: $variant) {
                ForEach(["A", "B", "C", "D"], id: \.self) { Text($0) }
            }
            .pickerStyle(.segmented)
            KabukiField(returnKeyType: returnKeyType)
                .id(variant)
                .frame(height: 44)
            Spacer()
        }
        .padding()
    }

    private var returnKeyType: UIReturnKeyType {
        switch variant {
        case "B": .go
        case "C": .search
        case "D": .join
        default: .default
        }
    }
}

/// A text field that prefers the prototype keyboard and grabs focus on appear.
struct KabukiField: UIViewRepresentable {
    let returnKeyType: UIReturnKeyType

    func makeUIView(context: Context) -> PrototypeTextField {
        let field = PrototypeTextField()
        field.borderStyle = .roundedRect
        field.placeholder = "Tapez ici"
        field.returnKeyType = returnKeyType
        DispatchQueue.main.async { field.becomeFirstResponder() }
        return field
    }

    func updateUIView(_ field: PrototypeTextField, context: Context) {}
}

final class PrototypeTextField: UITextField {
    // Prototype-only shortcut: ask for our keyboard by its (undocumented) identifier so screenshots
    // don't need a tap on the globe key. Real code must never do this.
    override var textInputMode: UITextInputMode? {
        UITextInputMode.activeInputModes.first {
            ($0.value(forKey: "identifier") as? String)?.contains("PrototypeTintKeyboard") == true
        } ?? super.textInputMode
    }
}
