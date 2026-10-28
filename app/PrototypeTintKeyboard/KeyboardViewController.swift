// PROTOTYPE, throwaway: answers "How does a Language Tint look inside the iOS 26 keyboard frame?"
// Four structurally different ways to paint a hard-coded light-blue tint, switchable with the
// "Variant ▶" key, or from the host app (it signals the variant through the field's return key type).
// Lives only on the prototype/tint-in-keyboard-frame branch. Never merge.

import UIKit

final class KeyboardViewController: UIInputViewController {
    private enum Variant: Int, CaseIterable {
        case plainFill, overdraw, insetCard, tintedGlass

        var label: String {
            switch self {
            case .plainFill: "A · Plain fill"
            case .overdraw: "B · Overdraw past the frame"
            case .insetCard: "C · Inset card"
            case .tintedGlass: "D · Tinted glass (55%)"
            }
        }
    }

    private let tint = UIColor(red: 0.70, green: 0.85, blue: 1.0, alpha: 1)
    private var variant = Variant.plainFill
    private var chosenByKey = false

    private let tintLayerView = UIView()
    private let stateLabel = UILabel()
    private let rows = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tintLayerView)

        stateLabel.font = .monospacedSystemFont(ofSize: 11, weight: .semibold)
        stateLabel.textAlignment = .center

        rows.axis = .vertical
        rows.spacing = 10
        rows.translatesAutoresizingMaskIntoConstraints = false
        rows.addArrangedSubview(stateLabel)
        rows.addArrangedSubview(row(["A", "Z", "E", "R", "T", "Y", "U", "I", "O", "P"]))
        rows.addArrangedSubview(row(["Q", "S", "D", "F", "G", "H", "J", "K", "L", "M"]))
        rows.addArrangedSubview(bottomRow())
        view.addSubview(rows)

        NSLayoutConstraint.activate([
            rows.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            rows.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -6),
            rows.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            rows.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8),
        ])
        apply()
    }

    // The host app picks a variant by setting the field's return key type.
    override func textDidChange(_ textInput: UITextInput?) {
        super.textDidChange(textInput)
        guard !chosenByKey else { return }
        switch textDocumentProxy.returnKeyType {
        case .go: variant = .overdraw
        case .search: variant = .insetCard
        case .join: variant = .tintedGlass
        default: variant = .plainFill
        }
        apply()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layoutTint()
    }

    private func apply() {
        view.backgroundColor = .clear
        view.clipsToBounds = true
        tintLayerView.layer.cornerRadius = 0
        tintLayerView.backgroundColor = tint

        switch variant {
        case .plainFill:
            view.backgroundColor = tint
            tintLayerView.backgroundColor = .clear
        case .overdraw:
            view.clipsToBounds = false
            var ancestor = view.superview
            while let v = ancestor { v.clipsToBounds = false; ancestor = v.superview }
        case .insetCard:
            tintLayerView.layer.cornerRadius = 22
        case .tintedGlass:
            tintLayerView.backgroundColor = tint.withAlphaComponent(0.55)
        }
        stateLabel.text = "\(variant.label)  ·  \(traitCollection.userInterfaceStyle == .dark ? "dark" : "light")"
        layoutTint()
    }

    private func layoutTint() {
        switch variant {
        case .overdraw: tintLayerView.frame = view.bounds.insetBy(dx: -300, dy: -300)
        case .insetCard: tintLayerView.frame = view.bounds.insetBy(dx: 4, dy: 4)
        default: tintLayerView.frame = view.bounds
        }
    }

    private func row(_ letters: [String]) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: letters.map { key($0, action: #selector(insert(_:))) })
        stack.distribution = .fillEqually
        stack.spacing = 6
        return stack
    }

    private func bottomRow() -> UIStackView {
        let globe = key("🌐", action: nil)
        globe.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
        let cycle = key("Variant ▶", action: #selector(nextVariant))
        let space = key("espace", action: #selector(insert(_:)))
        let stack = UIStackView(arrangedSubviews: [globe, cycle, space])
        stack.spacing = 6
        globe.widthAnchor.constraint(equalToConstant: 44).isActive = true
        cycle.widthAnchor.constraint(equalToConstant: 96).isActive = true
        return stack
    }

    private func key(_ title: String, action: Selector?) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20)
        button.setTitleColor(.label, for: .normal)
        button.backgroundColor = UIColor { $0.userInterfaceStyle == .dark ? UIColor(white: 0.42, alpha: 1) : .white }
        button.layer.cornerRadius = 6
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        if let action { button.addTarget(self, action: action, for: .touchUpInside) }
        return button
    }

    @objc private func insert(_ sender: UIButton) {
        let title = sender.title(for: .normal) ?? ""
        textDocumentProxy.insertText(title == "espace" ? " " : title.lowercased())
    }

    @objc private func nextVariant() {
        chosenByKey = true
        variant = Variant(rawValue: (variant.rawValue + 1) % Variant.allCases.count)!
        apply()
    }
}
