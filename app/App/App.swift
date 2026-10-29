// DIAGNOSTIC host app (branch task/on-device-checks, never merge).
// Writes a Language Tint to the App Group, lists the active input modes, and offers fields
// with different return-key types for checking Apple's French keyboard by hand.

import SwiftUI
import UIKit

@main
struct HelloApp: App {
    var body: some Scene {
        WindowGroup {
            DiagnosticView()
        }
    }
}

struct DiagnosticView: View {
    private let groupID = "group.com.keyboardkabuki.app"
    @Environment(\.scenePhase) private var scenePhase
    @State private var written = "—"
    @State private var modes: [String] = []
    @State private var modesCheckedAt = "—"
    @State private var plain = ""
    @State private var search = ""
    @State private var send = ""

    private let tints = [("Light blue", "#B2D8FF"), ("Light red", "#FFC2C2"), ("Light green", "#C8F0C8")]

    var body: some View {
        NavigationStack {
            Form {
                Section("1 · Language Tint in the App Group") {
                    HStack {
                        ForEach(tints, id: \.1) { name, hex in
                            Button(name) { write(hex) }.buttonStyle(.bordered)
                        }
                    }
                    Text("Last written: \(written)").font(.caption.monospaced())
                }
                Section("2 · Try the keyboard") {
                    TextField("Plain field (return = default)", text: $plain)
                    TextField("Search field", text: $search).submitLabel(.search)
                    TextField("Send field", text: $send).submitLabel(.send)
                }
                Section("3 · Active input modes (refreshes when you come back)") {
                    ForEach(modes, id: \.self) { Text($0).font(.caption.monospaced()) }
                    Text("Checked at \(modesCheckedAt)").font(.caption2).foregroundStyle(.secondary)
                    Button("Refresh") { refreshModes() }
                }
                Section("4 · Settings") {
                    Button("Open this app's Settings page") {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    }
                }
            }
            .navigationTitle("On-device checks")
        }
        .onAppear { refreshModes(); written = UserDefaults(suiteName: groupID)?.string(forKey: "tintHex") ?? "— (nothing yet)" }
        .onChange(of: scenePhase) { _, phase in if phase == .active { refreshModes() } }
    }

    private func write(_ hex: String) {
        guard let defaults = UserDefaults(suiteName: groupID) else { written = "App Group unavailable"; return }
        defaults.set(hex, forKey: "tintHex")
        written = "\(hex) at \(Date().formatted(date: .omitted, time: .standard))"
    }

    private func refreshModes() {
        // Diagnostic only: `identifier` is undocumented and is read here just to tell keyboards apart.
        modes = UITextInputMode.activeInputModes.map { mode in
            let id = (mode.value(forKey: "identifier") as? String) ?? "?"
            return "\(mode.primaryLanguage ?? "nil")  ·  \(id)"
        }
        modesCheckedAt = Date().formatted(date: .omitted, time: .standard)
    }
}
