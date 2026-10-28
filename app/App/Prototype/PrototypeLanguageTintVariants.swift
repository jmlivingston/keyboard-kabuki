// PROTOTYPE, throwaway (branch prototype/language-tint-screen, never merge).
// Plan: three structurally different Language Tint screens on the app's root, switchable from a
// floating bar (or `-variant B` at launch). State is in memory only; nothing reaches the keyboard.
//
// A · List → detail: Kabuki Keyboards list, push to a detail with the picker and a big preview.
// B · Preview first: one screen, big preview on top, inline picker with opacity, preset swatches.
// C · Tap the keyboard: the preview *is* the control; tapping it opens the system color picker sheet.

import SwiftUI
import UIKit

/// Placeholder default; whether French has a default tint is still open on the map.
let prototypeDefaultTint = Color(red: 0.70, green: 0.85, blue: 1.0)

struct VariantA: View {
    @Binding var tint: Color

    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        detail
                    } label: {
                        HStack {
                            Circle().fill(tint).frame(width: 28, height: 28)
                                .overlay(Circle().stroke(.secondary.opacity(0.3)))
                            VStack(alignment: .leading) {
                                Text("Français (France)")
                                Text("AZERTY").font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                } header: {
                    Text("Kabuki Keyboards")
                } footer: {
                    Text("Each Kabuki Keyboard shows its own Language Tint.")
                }
                Section("Setup") {
                    Label("Add the keyboard in Settings", systemImage: "keyboard")
                }
                Section("Privacy") {
                    Label("No Full Access. Nothing you type is read or kept.", systemImage: "lock")
                }
            }
            .navigationTitle("Keyboard Kabuki")
        }
    }

    private var detail: some View {
        List {
            Section {
                PrototypeKeyboardPreview(tint: tint)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }
            Section {
                ColorPicker("Language Tint", selection: $tint, supportsOpacity: false)
                Button("Reset to default") { tint = prototypeDefaultTint }
            } footer: {
                Text("Switch to the keyboard again to see the new tint.")
            }
        }
        .navigationTitle("Français (France)")
    }
}

struct VariantB: View {
    @Binding var tint: Color
    private let presets: [Color] = [
        prototypeDefaultTint, Color(red: 1, green: 0.8, blue: 0.8), Color(red: 0.8, green: 0.95, blue: 0.8),
        Color(red: 1, green: 0.93, blue: 0.7), Color(red: 0.88, green: 0.82, blue: 1), Color(white: 0.2),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Français (France)").font(.largeTitle.bold())
            PrototypeKeyboardPreview(tint: tint)
            HStack(spacing: 12) {
                ForEach(presets.indices, id: \.self) { i in
                    Circle().fill(presets[i]).frame(width: 36, height: 36)
                        .overlay(Circle().stroke(.secondary.opacity(0.3)))
                        .onTapGesture { tint = presets[i] }
                }
                Spacer()
                ColorPicker("", selection: $tint, supportsOpacity: true).labelsHidden()
            }
            Text("Opacity is allowed here: see how a see-through tint reads against the keyboard frame.")
                .font(.footnote).foregroundStyle(.secondary)
            Spacer()
            Text("Setup · Privacy").font(.footnote).foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
        }
        .padding()
    }
}

struct VariantC: View {
    @Binding var tint: Color
    @State private var showingPicker = false

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                Text("Tap a keyboard to change its tint")
                    .font(.headline).foregroundStyle(.secondary)
                    .padding(.top, 40)
                VStack(spacing: 8) {
                    PrototypeKeyboardPreview(tint: tint)
                        .onTapGesture { showingPicker = true }
                    Text("Français (France)").font(.subheadline)
                }
                VStack(spacing: 8) {
                    PrototypeKeyboardPreview(tint: Color(white: 0.6).opacity(0.3), compact: true)
                        .opacity(0.4)
                    Text("More languages later").font(.caption).foregroundStyle(.secondary)
                }
                .padding(.horizontal, 60)
            }
            .padding()
        }
        .sheet(isPresented: $showingPicker) {
            SystemColorPicker(tint: $tint)
                .presentationDetents([.medium, .large])
        }
    }
}

/// The full system picker (UIColorPickerViewController): grid, spectrum, sliders and eyedropper.
struct SystemColorPicker: UIViewControllerRepresentable {
    @Binding var tint: Color

    func makeUIViewController(context: Context) -> UIColorPickerViewController {
        let picker = UIColorPickerViewController()
        picker.supportsAlpha = false
        picker.selectedColor = UIColor(tint)
        picker.title = "Français (France)"
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ picker: UIColorPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(tint: $tint) }

    final class Coordinator: NSObject, UIColorPickerViewControllerDelegate {
        let tint: Binding<Color>
        init(tint: Binding<Color>) { self.tint = tint }
        func colorPickerViewController(_ picker: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
            tint.wrappedValue = Color(color)
        }
    }
}
