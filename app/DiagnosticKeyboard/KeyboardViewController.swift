// DIAGNOSTIC, throwaway (branch task/on-device-checks, never merge).
// Test keyboard for "Run the on-device checks the research left open". Full Access is OFF.
// It shows on screen: whether it can read the App Group, when it read it, whether the value changes
// while it's open, and buttons that try each kind of haptic and the input click.

import UIKit

final class KeyboardViewController: UIInputViewController {
    private let groupID = "group.com.keyboardkabuki.app"
    private let status = UILabel()
    private var lastSeen: String?
    private var pollTimer: Timer?
    private var liveChanges = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        status.font = .monospacedSystemFont(ofSize: 11, weight: .medium)
        status.numberOfLines = 0

        let haptics = UIStackView(arrangedSubviews: [
            button("Impact") { UIImpactFeedbackGenerator(style: .medium).impactOccurred() },
            button("Select") { UISelectionFeedbackGenerator().selectionChanged() },
            button("Notify") { UINotificationFeedbackGenerator().notificationOccurred(.success) },
            button("Click") { UIDevice.current.playInputClick() },
        ])
        haptics.distribution = .fillEqually
        haptics.spacing = 6

        let typing = UIStackView(arrangedSubviews: [
            button("🌐 next") { [weak self] in self?.advanceToNextInputMode() },
            button("type “a”") { [weak self] in self?.textDocumentProxy.insertText("a") },
            button("⌫") { [weak self] in self?.textDocumentProxy.deleteBackward() },
        ])
        typing.distribution = .fillEqually
        typing.spacing = 6

        let stack = UIStackView(arrangedSubviews: [status, haptics, typing])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            stack.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8),
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        liveChanges = 0
        readGroup(reason: "viewWillAppear")
        // Polls once a second to see if a tint change made in the app shows up while we're open.
        pollTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.readGroup(reason: "poll")
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pollTimer?.invalidate()
    }

    private func readGroup(reason: String) {
        let defaults = UserDefaults(suiteName: groupID)
        let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupID)
        let hex = defaults?.string(forKey: "tintHex")
        if reason == "poll", hex != lastSeen { liveChanges += 1 }
        if reason == "viewWillAppear" || hex != lastSeen {
            lastSeen = hex
            view.backgroundColor = hex.flatMap(UIColor.init(hex:)) ?? .systemGray5
        }
        let time = Date().formatted(date: .omitted, time: .standard)
        status.text = """
        Full Access: \(hasFullAccess ? "ON" : "off")   iOS \(UIDevice.current.systemVersion)
        App Group defaults: \(defaults == nil ? "nil" : "ok")   container: \(containerURL == nil ? "nil" : "ok")
        tintHex read: \(hex ?? "— (nothing)")   at \(time)
        changes seen while open: \(liveChanges)
        """
    }

    private func button(_ title: String, action: @escaping () -> Void) -> UIButton {
        let button = UIButton(type: .system, primaryAction: UIAction(title: title) { _ in action() })
        button.backgroundColor = .systemBackground
        button.layer.cornerRadius = 6
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        return button
    }
}

// Lets the input click play when the user has keyboard clicks on (it still needs Full Access per Apple).
extension KeyboardViewController: UIInputViewAudioFeedback {
    var enableInputClicksWhenVisible: Bool { true }
}

extension UIColor {
    convenience init?(hex: String) {
        guard hex.count == 7, hex.hasPrefix("#"), let value = Int(hex.dropFirst(), radix: 16) else { return nil }
        self.init(red: CGFloat((value >> 16) & 0xFF) / 255, green: CGFloat((value >> 8) & 0xFF) / 255,
                  blue: CGFloat(value & 0xFF) / 255, alpha: 1)
    }
}
