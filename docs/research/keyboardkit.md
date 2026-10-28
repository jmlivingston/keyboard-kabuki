# Can KeyboardKit give us a French (AZERTY) keyboard with a custom background, no Full Access, and no reading of document context?

Researched 2026-10-28 against primary sources:

- the KeyboardKit GitHub repo, at tag **11.1.3** (commit `b9cb190`, 2026-10-26), which is the current release;
- the KeyboardKit DocC documentation at docs.keyboardkit.com, read through its JSON data endpoints (`https://docs.keyboardkit.com/data/documentation/keyboardkit/<path>.json`) because the HTML is rendered client-side. The URLs cited below are the human-readable equivalents;
- keyboardkit.com: the Pro, pricing, business, license-handling, FAQ, about, and privacy pages;
- the LicenseKit repo at 2.3.0 (KeyboardKit's license dependency);
- Apple's "Configuring open access for a custom keyboard".

Labels used below: **[Doc]** means stated in a primary source, **[Inference]** means my reasoning from documented facts, and **[Unverified]** means not confirmable from public sources.

> **Two surprises that change the premise**
>
> 1. KeyboardKit is **no longer open source**. Since v11 it is shipped as a closed-source binary under a "Closed Source License". The README still says "free, open-source keyboard engine" in one place, but its LICENSE and FAQ say closed source.
> 2. **A standard KeyboardKit Pro license needs Full Access.** Standard licenses validate over the network, so the keyboard needs Full Access. Only the Business licenses, which start at **$10k/year**, validate on device.

---

## TL;DR

**KeyboardKit does not "extend" Apple's French keyboard.** It reimplements a native-looking keyboard in SwiftUI. That is the same thing our own custom keyboard would have to do anyway (see `system-keyboard-tinting.md`).

How each tier fits the four requirements (French AZERTY, arbitrary background color, no Full Access, no reading of document context):

| Route | French AZERTY + accent callouts | Arbitrary background color | No Full Access | No reading of context | Cost |
|---|---|---|---|---|---|
| **Free KeyboardKit** | Not built in. Free has a QWERTY input set and English callouts only. AZERTY and the French layout and callouts are Pro features. You could hand-build them with the public `InputSet(rows:)`, layout mutations, and `.keyboardCalloutActions` **[Inference]**. | Yes. `KeyboardViewStyle(background: .color(…))` via `.keyboardViewStyle(_:)` is not marked Pro. | Yes, according to the FAQ. | Mostly. Turn off autocapitalization. Autocomplete is a disabled service in free. The closed binary can't be audited. | $0 |
| **Pro Basic / Silver / Gold** (standard licenses) | Yes. Basic covers 1 language, Silver 5, Gold 110+. | Yes. Themes are Gold and above, but `KeyboardViewStyle` alone is enough. | **No.** Standard licenses validate over the network and need Full Access. | Configurable | $50, $150, or $500 per month ($500, $1,500, or $5,000 per year) |
| **Pro Business** | Yes | Yes | **Yes.** It uses an on-device license file. | Configurable | **$10k/year** and up |

**Verdict:** No affordable KeyboardKit tier meets all four requirements out of the box.

- Pro would give us French, but under the privacy rule only a $10k/year Business license is usable.
- Free KeyboardKit meets the privacy and color requirements, but we would still have to build the French layout and accents ourselves. We would also be taking on a closed-source binary whose privacy policy allows "anonymous usage statistics".

For this app, that weakens the case for KeyboardKit compared with writing a small custom keyboard ourselves **[Inference]**.

---

## 1. What KeyboardKit is: it reimplements the keyboard, it does not wrap Apple's

**[Doc]**
- The README says KeyboardKit "lets you create amazing custom keyboard extensions … using Swift & SwiftUI". It says it "extends Apple's limited keyboard **APIs** with more capabilities". That refers to the APIs (`UIInputViewController`, `UITextDocumentProxy`), not Apple's keyboard. [README](https://github.com/KeyboardKit/KeyboardKit/blob/master/README.md)
- `KeyboardView` "mimics the native iOS keyboard". The README calls it a way to "Render a native-looking, fully customizable keyboard". [Essentials - KeyboardView](https://docs.keyboardkit.com/documentation/keyboardkit/essentials-keyboardview), [README](https://github.com/KeyboardKit/KeyboardKit/blob/master/README.md)
- The Styling article says the color/image/font assets exist "to make it easy to create keyboards that look like a native iOS keyboard". [Styling](https://docs.keyboardkit.com/documentation/keyboardkit/styling-article)
- KeyboardKit's own FAQ describes a custom keyboard as "a third-party keyboard extension that can replace the native iOS keyboard". [FAQ](https://keyboardkit.com/faq)

**[Inference]** This confirms the expectation. Every key is drawn by KeyboardKit's SwiftUI views, and nothing of Apple's French keyboard is reused. "Extend a French keyboard" in KeyboardKit terms means using KeyboardKit Pro's own French locale data (layout, callouts, strings).

## 2. French (France) / AZERTY support

**[Doc]**
- `.french` (fr) is in the supported-locale list. fr_CA, fr_BE, and fr_CH are also listed. [Localization](https://docs.keyboardkit.com/documentation/keyboardkit/localization-article)
- Locale support is gated behind Pro:
  - The README says "KeyboardKit Pro unlocks localized keyboards, layouts, callouts and behaviors for all supported locales." [README](https://github.com/KeyboardKit/KeyboardKit/blob/master/README.md)
  - The Localization article says "👑 KeyboardKit Pro can be used to unlock supported locales." [Localization](https://docs.keyboardkit.com/documentation/keyboardkit/localization-article)
- AZERTY is Pro:
  - "KeyboardKit defines basic input sets like qwerty, numeric and symbolic, while KeyboardKit Pro unlocks extra input sets like qwertz, azerty, colemak, dvorak and locale-specific sets." [KeyboardLayout.InputSet](https://docs.keyboardkit.com/documentation/keyboardkit/keyboardlayout/inputset)
  - `InputSet.azerty` is `static var azerty: Self { get throws }`, with the note "This requires that your license unlocks the inputSets feature." [InputSet.azerty](https://docs.keyboardkit.com/documentation/keyboardkit/keyboardlayout/inputset/azerty)
  - The Layout article says localized builders "will throw a license error if you use them without a valid license. If you're on a Basic or Silver plan, you must specify locales in your KeyboardApp." [Layout](https://docs.keyboardkit.com/documentation/keyboardkit/layout-article)
- **What free gives you:**
  - The `qwerty` input set (a non-throwing `static var qwerty`). [InputSet.qwerty](https://docs.keyboardkit.com/documentation/keyboardkit/keyboardlayout/inputset/qwerty)
  - Layout mutations: insert, remove, and replace. [Layout](https://docs.keyboardkit.com/documentation/keyboardkit/layout-article)
  - A public `InputSet.init(rows:)`. [InputSet](https://docs.keyboardkit.com/documentation/keyboardkit/keyboardlayout/inputset)
  - Localized UI strings for each locale via `KKL10n`. [Localization](https://docs.keyboardkit.com/documentation/keyboardkit/localization-article)
- **Callouts (é è ê ë à ç …):**
  - Localized callouts are Pro: "KeyboardKit Pro unlocks localized secondary callout actions for all keyboardKitSupported locales in your license." [Callouts](https://docs.keyboardkit.com/documentation/keyboardkit/callouts-article)
  - Free has "standard, english actions". [KeyboardCalloutActions](https://docs.keyboardkit.com/documentation/keyboardkit/keyboardcalloutactions)
  - The `.keyboardCalloutActions { params in … }` modifier for custom callouts is documented without a Pro marker. [Callouts](https://docs.keyboardkit.com/documentation/keyboardkit/callouts-article)
- Basic covers 1 language, Silver 5, and Gold/Business 76 in the comparison table (110+ in the headline). [Pricing](https://keyboardkit.com/pricing)

**[Inference]**
- On free KeyboardKit, French AZERTY means defining the AZERTY rows ourselves with `InputSet(rows:)` and the French accent callouts with `.keyboardCalloutActions`.
- That is technically possible, but it is the same data we would have to write without KeyboardKit.

**[Unverified]** Whether custom `InputSet(rows:)` use or layout mutations trigger any license check. The binary can't be inspected.

**[Doc]** Language counts disagree across first-party pages: 75 (README flags), 76 (pricing table), 110+ / 111 (docs and FAQ), and 117 (About page). The cause is probably locales versus layout variants **[Inference]**.

## 3. Background color / theming

**[Doc]**
- `KeyboardViewStyle` has `init(background: Keyboard.BackgroundStyle? = nil, backgroundCornerRadiusTop:, backgroundCornerRadiusBottom:, foregroundColor:, edgeInsets:)`. It is applied with `.keyboardViewStyle(_:)`. [KeyboardViewStyle](https://docs.keyboardkit.com/documentation/keyboardkit/keyboardviewstyle), [keyboardViewStyle(_:)](https://docs.keyboardkit.com/documentation/keyboardkit/swiftuicore/view/keyboardviewstyle(_:))
- `Keyboard.BackgroundStyle` has `static func color(_ color: Color)`, plus gradient, image, and overlay layers. It was added as "a new, separate background style type" in v11. [Keyboard.BackgroundStyle](https://docs.keyboardkit.com/documentation/keyboardkit/keyboard/backgroundstyle), [RELEASE_NOTES](https://github.com/KeyboardKit/KeyboardKit/blob/master/RELEASE_NOTES.md)
- None of these pages carries a Pro marker. Pages for Pro features do say so explicitly.
- **Themes** (`KeyboardTheme`, `.keyboardTheme(_:)`, predefined themes) are Pro: "👑 KeyboardKit Pro unlocks a theme engine for all licenses that include the themes feature". [Themes](https://docs.keyboardkit.com/documentation/keyboardkit/themes-article)
- The pricing comparison table lists Themes only for Gold and Business. [Pricing](https://keyboardkit.com/pricing)
- **iOS 26 / Liquid Glass:**
  - `KeyboardContext` has `isLiquidGlassAvailable` and a settable `isLiquidGlassEnabled`. [isLiquidGlassEnabled](https://docs.keyboardkit.com/documentation/keyboardkit/keyboardcontext/isliquidglassenabled)
  - The `KeyboardViewStyle` docs say: "while KeyboardContext allows us to disable the liquid glass keyboard design, the style still uses the true value to determine the corner radius, since the keyboard system frame can't be changed." [KeyboardViewStyle](https://docs.keyboardkit.com/documentation/keyboardkit/keyboardviewstyle)
- The standard KeyboardKit keyboard colors are deliberately semi-transparent to work around an iOS color-scheme bug. [Styling](https://docs.keyboardkit.com/documentation/keyboardkit/styling-article)

**[Inference]**
- An arbitrary background color is available in free KeyboardKit:
  ```swift
  KeyboardView(…).keyboardViewStyle(.init(background: .color(userColor)))
  ```
- On iOS 26, the colored area will sit inside the rounded system frame. The corners and the region outside them stay system-drawn.
- The containing app can write the color to the App Group, and the keyboard can read it without Full Access. Apple gives non-open-access keyboards "read-only access to the containing app's shared containers". [Apple: Configuring open access](https://developer.apple.com/documentation/uikit/configuring-open-access-for-a-custom-keyboard)

**[Unverified]** How the custom color looks behind iOS 26 key materials. This needs a device test.

## 4. Privacy & permissions

**Full Access / network**

**[Doc]**
- The FAQ says: "KeyboardKit works without Full Access although standard licenses use Full Access to perform network validation. Business licenses do not require Full Access." [FAQ](https://keyboardkit.com/faq)
- The license-handling page says: "All standard licenses are validated over a network call to a license server. This means that a keyboard needs Full Access to be able to validate its license key. KeyboardKit caches licenses to handle temporary connectivity loss." [License Validation](https://keyboardkit.com/pro/license-handling)
- It also says: "All business licenses are validated on-device … delivered on a file". [License Validation](https://keyboardkit.com/pro/license-handling)
- On a license error, the controller "will by default show a license error alert". [viewWillHandleLicenseError(_:)](https://docs.keyboardkit.com/documentation/keyboardkit/keyboardinputviewcontroller/viewwillhandlelicenseerror(_:))
- LicenseKit 2.3.0, the underlying dependency, is also closed source. It integrates with "any 3rd party API, like Gumroad" and "can cache licenses". [LicenseKit README](https://github.com/LicenseKit/LicenseKit/blob/2.3.0/README.md)
- The KeyboardKit Demo keyboard sets `RequestsOpenAccess = true`. [Demo/Keyboard/Info.plist](https://github.com/KeyboardKit/KeyboardKit/blob/master/Demo/Keyboard/Info.plist)

**Autocomplete, dictation, host app, and haptics**

**[Doc]**
- Pro autocomplete is "on-device". Free uses a `disabled` autocomplete service. `StandardAutocompleteService` can optionally call a `RemoteAutocompleteRequest`, and the README sample shows `.claude(...)` next-word prediction. [Autocomplete](https://docs.keyboardkit.com/documentation/keyboardkit/autocomplete-article), [README](https://github.com/KeyboardKit/KeyboardKit/blob/master/README.md)
- Dictation is Pro. It opens the main app, because keyboards can't use the microphone, and it lives in a separate plugin so that the microphone permission strings are only needed if you use it. [Dictation](https://docs.keyboardkit.com/documentation/keyboardkit/dictation-article)
- Host-app detection is isolated in `KeyboardKitHostPlugin` "to avoid having system API usages in KeyboardKit". [Host](https://docs.keyboardkit.com/documentation/keyboardkit/host-article)
- `KeyboardFeedbackContext` exposes `isHapticFeedbackAvailable`, and feedback can be disabled with `feedbackSettings.isAudioFeedbackEnabled` and `isHapticFeedbackEnabled`. [Feedback](https://docs.keyboardkit.com/documentation/keyboardkit/feedback-article)

**[Unverified]** Which feedback types work without Full Access. Apple lists "No access to microphone and speaker" for non-open-access keyboards. [Apple: Configuring open access](https://developer.apple.com/documentation/uikit/configuring-open-access-for-a-custom-keyboard)

**Reading document context**

**[Doc]**
- `autocompleteText`: "All available text before the text input cursor will be used by default." `performAutocomplete()` is called automatically "when the current text changes or the input cursor is moved". [autocompleteText](https://docs.keyboardkit.com/documentation/keyboardkit/keyboardinputviewcontroller/autocompletetext), [Autocomplete](https://docs.keyboardkit.com/documentation/keyboardkit/autocomplete-article)
- `preferredKeyboardCase(for:locale:isAutocapitalizationEnabled:)` resolves the shift state "from the textDocumentProxy". It is controlled by `KeyboardSettings.isAutocapitalizationEnabled`. [preferredKeyboardCase](https://docs.keyboardkit.com/documentation/keyboardkit/keyboardinputviewcontroller/preferredkeyboardcase(for:locale:isautocapitalizationenabled:)), [Essentials](https://docs.keyboardkit.com/documentation/keyboardkit/essentials-article)
- Other context-reading features:
  - `isPeriodShortcutEnabled` (double-space for a period).
  - The proxy extensions: `currentWord`, `isCursorAtNewSentence`, and so on.
  - Pro `fullDocumentContext`, which moves the cursor to read more text.
  - The Pro undo manager, which is on by default (`isUndoManagerEnabled` is now `true` by default).
  [Essentials](https://docs.keyboardkit.com/documentation/keyboardkit/essentials-article), [Proxy](https://docs.keyboardkit.com/documentation/keyboardkit/proxy-article), [RELEASE_NOTES](https://github.com/KeyboardKit/KeyboardKit/blob/master/RELEASE_NOTES.md)

**[Inference]** Settings exist to turn these off: `isAutocapitalizationEnabled = false`, `isPeriodShortcutEnabled = false`, and autocomplete disabled or left as free's disabled service. Because the framework is a closed binary, though, **we can't verify that it never calls `documentContextBeforeInput`**. For example, `textDidChange` handling or the custom proxy wrapper may read it.

**[Doc]** Without Full Access, iOS itself guarantees that "keystrokes can't be sent back to your server or anywhere else". [Apple: Configuring open access](https://developer.apple.com/documentation/uikit/configuring-open-access-for-a-custom-keyboard) So any context reads would stay on device.

**Analytics / telemetry: the first-party sources contradict each other**

**[Doc]**
- The FAQ says "KeyboardKit does not collect, store, or transmit any user data." [FAQ](https://keyboardkit.com/faq)
- The privacy policy, last updated 2026-08-31, says "The Software may collect anonymous usage statistics and crash reports". It lists "Usage Statistics", "Crash Reports", and "Performance Metrics", stored "within the Software until it's synced to cloud-storage", and possibly shared with "Analytics Services: Third-party services". [Privacy Policy](https://keyboardkit.com/privacy)

**[Inference]** Without Full Access, the keyboard extension can't send that data. The containing app does have network access, so if KeyboardKit is also used there (`KeyboardAppView`), it could.

**[Unverified]** Whether the binary actually ships any telemetry.

## 5. Licensing & cost

**[Doc]**
- **Free KeyboardKit license:**
  - LICENSE is titled "Closed Source License". It says: "KeyboardKit … is closed-source. The Software is free to start using and has commercial pro features that require a valid license", and it forbids reverse engineering. [LICENSE](https://github.com/KeyboardKit/KeyboardKit/blob/master/LICENSE)
  - The FAQ says: "The KeyboardKit SDK is closed source, but freely available from GitHub … You can freely use KeyboardKit in any app." [FAQ](https://keyboardkit.com/faq)
  - The package ships `binaryTarget`s downloaded from `KeyboardKit-Binaries`. [Package.swift](https://github.com/KeyboardKit/KeyboardKit/blob/master/Package.swift)
- **Pro standard tiers** are monthly or annual (annual saves 17%). They are bought via Gumroad, cover one app, and auto-renew. [Pricing](https://keyboardkit.com/pricing)

| Tier | Price | What it includes |
|---|---|---|
| Basic | $50/month or $500/year | 1 language, autocomplete and autocorrect |
| Silver | $150/month or $1,500/year | 5 languages, AI, in-keyboard typing |
| Gold | $500/month or $5,000/year | 110+ languages, all Pro features, including themes, emoji keyboard, dictation, and host utils |

- **Business tiers:** Business $10k/year, Business+ $25k/year, Enterprise from $50k/year. They include an "On-Device License File" and "On-Device License Validation … without requiring Full Access". A Business license is *required* above $10M company revenue or $1M app revenue. [Business](https://keyboardkit.com/business)
- **Trial:** a 7-day free trial, "No credit card required". [Pricing](https://keyboardkit.com/pricing), [Pro](https://keyboardkit.com/pro)
- **License key:** passed as `KeyboardApp(licenseKey:)`. Pro also unlocks "if you have added a license file to your app bundle" (Business). [Getting Started](https://docs.keyboardkit.com/documentation/keyboardkit/getting-started-article)

**[Inference]** French alone needs at least Basic, because a single language is enough. Under the no-Full-Access rule, though, the cheapest working Pro option is Business at $10k/year.

## 6. Platform & setup

**[Doc]**
- **Platform:** `Package.swift` declares `.iOS(.v16)` and Swift tools 6.2. macOS, tvOS, watchOS, and visionOS are commented out. [Package.swift](https://github.com/KeyboardKit/KeyboardKit/blob/master/Package.swift)
- **Linking:** KeyboardKit is a binary target and "must ONLY be added to the app target. If you add it to any other target, it may crash at runtime". The keyboard finds it via runpath (`@executable_path/../../Frameworks`). [Getting Started](https://docs.keyboardkit.com/documentation/keyboardkit/getting-started-article)
- **Setup:**
  1. Define a shared `KeyboardApp` with `name`, an optional `licenseKey`, an `appGroupId`, and `locales`.
  2. Make the keyboard's principal class subclass `KeyboardInputViewController`.
  3. Override `viewWillSetupKeyboardKit()` and call `setupKeyboardKit(for:)`.
  4. Optionally override `viewWillSetupKeyboardView()` and call `setupKeyboardView { controller in KeyboardView(…) }`.
  5. Optionally wrap the app root in `KeyboardAppView(for:)`.

  It is all SwiftUI. [Getting Started](https://docs.keyboardkit.com/documentation/keyboardkit/getting-started-article), [KeyboardInputViewController](https://docs.keyboardkit.com/documentation/keyboardkit/keyboardinputviewcontroller)
- The README sample still uses an older `setup(for:)` call. The docs use `setupKeyboardKit(for:)`. [README](https://github.com/KeyboardKit/KeyboardKit/blob/master/README.md)
- **Settings sync:** `KeyboardSettings` are `@AppStorage` values synced through the App Group. [Essentials](https://docs.keyboardkit.com/documentation/keyboardkit/essentials-article)

**[Inference]** Without Full Access, the keyboard can only *read* the App Group (per Apple). Any KeyboardKit settings the keyboard tries to persist there would not be shared back to the app.

---

## Implications for Keyboard Kabuki

1. **"Extending" Apple's French keyboard isn't possible, with or without KeyboardKit.** KeyboardKit is a reimplementation, which is consistent with `system-keyboard-tinting.md`.
2. **KeyboardKit Pro on a standard license (Basic, Silver, or Gold) conflicts with the hard privacy rule.** It needs Full Access for license validation. The only compliant Pro path is a $10k+/year Business license.
3. **Free KeyboardKit meets the color and no-Full-Access requirements, but not French out of the box.** We would hand-write the AZERTY rows and accent callouts. The value KeyboardKit adds is then mostly key rendering, gestures, and the shift/caps state machine.
4. **Auditability.** Free KeyboardKit is now a closed binary with a privacy policy that allows analytics. A "never reads context" promise can't be verified by code review. A small in-house SwiftUI keyboard (an AZERTY grid, a long-press accent popup, shift, numbers and symbols, a globe key, and a background color read from the App Group) is likely a modest amount of code and fully auditable **[Inference]**.

## Open questions

- Does any free KeyboardKit code path read `documentContextBeforeInput` or `documentContextAfterInput` when autocapitalization and autocomplete are off? This can only be tested empirically, for example with a proxy-wrapping test or by logging.
- Can a standard Pro license validated in the containing app (which has network access) be cached and reused by the keyboard without Full Access? The docs say the *keyboard* needs Full Access. One option is to ask info@keyboardkit.com.
- Does the free binary perform any telemetry, in either the app or the keyboard? The FAQ and the privacy policy disagree.
- Does building a custom `InputSet(rows:)` or using `.keyboardCalloutActions` in free trigger any license gate?
- How does a solid custom background render inside the iOS 26 rounded system frame? This needs a device test.
- Which audio and haptic feedback works in a keyboard without Full Access?
