# Can a Kabuki Keyboard play key clicks and haptics without Full Access?

Researched 2026-10-28 against Apple primary sources: UIKit and Core Haptics reference, the archived *App Extension Programming Guide*, the Human Interface Guidelines, and the iPhone User Guide. Developer-doc pages were read through their JSON data endpoints (`https://developer.apple.com/tutorials/data/documentation/<path>.json`), because the HTML renders client-side. The URLs below are the human-readable equivalents. Apple Developer Forums threads and KeyboardKit are supporting evidence only and are labelled as such.

Labels: **[Doc]** means Apple states it. **[Inferred]** is my reading of Apple text. **[Unverified]** means no primary source was found, so it needs a device test.

## TL;DR

- **Key clicks: documented as needing Full Access.** Apple's custom-keyboard guide lists "Ability to play audio, including keyboard clicks using the playInputClick method" as a capability a keyboard *gains* with `RequestsOpenAccess = YES`. Today's open-access page says that without open access a keyboard has "No access to microphone and speaker". Plan on a Kabuki Keyboard with Full Access off being **silent**.
- **Haptics: not documented either way.** No Apple page lists haptics, the Taptic Engine, or `UIFeedbackGenerator` as an open-access capability or restriction. The haptics docs don't mention app extensions. The one condition that could bite is "When the app is running in the foreground", and Apple doesn't say how it applies to a keyboard extension process. KeyboardKit, a third-party framework, tells users to enable Full Access for "audio and haptic feedback", but cites no Apple source. **Only a device test can settle this.**
- **Settings:** `playInputClick()` is documented to respect the user's keyboard-click setting. Feedback generators are documented to respect the system Haptics setting. No public API reads Settings › Sounds & Haptics › Keyboard Feedback › Haptic, and no source says third-party keyboards are bound by it.
- **iOS 18 vs 26:** no Apple page found that changes any of this between versions. The current open-access page carries no version-specific notes.

## Findings

### 1. What Apple says Full Access controls

- **[Doc] Without open access, a keyboard has "No access to microphone and speaker".** The same list includes "Ability to perform all the normal duties expected of a basic keyboard" and read-only access to the containing app's shared containers. Haptics, vibration, and the Taptic Engine are not in either list. [Configuring open access for a custom keyboard](https://developer.apple.com/documentation/uikit/configuring-open-access-for-a-custom-keyboard)
- **[Doc] The archived App Extension Programming Guide is more specific.** Under `RequestsOpenAccess`, setting it to `YES` gives "the following capabilities", and one of them is "Ability to play audio, including keyboard clicks using the playInputClick method". The guide also says the key "expresses whether a custom keyboard wants to enlarge its sandbox beyond that needed for a basic keyboard". The page was last updated 2017-10-19 and is archived. [App Extension Programming Guide: Custom Keyboard](https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/CustomKeyboard.html)
- **[Inferred] "No access to … speaker" in the current docs is the same rule as the archive's "Ability to play audio, including keyboard clicks", reworded.** Both are in the same position in the capability lists, and the current page drops no other item that would account for it. Apple doesn't state the equivalence on the current page.
- **[Doc] The archive guide also says that "Custom keyboards, like all app extensions in iOS 8.0, have no access to the device microphone".** This applies whether or not open access is on, and it is unrelated to output. [Same guide](https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/CustomKeyboard.html)

### 2. Key clicks (`UIDevice.playInputClick()` / `UIInputViewAudioFeedback`)

- **[Doc] Apple's purpose for `playInputClick()`:** "Use this method to play the standard system keyboard click in response to a user tapping in a custom input or keyboard accessory view. A click plays only if the user has enabled keyboard clicks in Settings > Sounds, and only if the input view is itself enabled and visible." [playInputClick()](https://developer.apple.com/documentation/uikit/uidevice/playinputclick())
- **[Doc] To opt in, the input view adopts `UIInputViewAudioFeedback` and returns `true` from `enableInputClicksWhenVisible`.** That property is "`false` by default", and "Input clicks will be produced only if the user has also enabled keyboard clicks in Settings > Sounds." [UIInputViewAudioFeedback](https://developer.apple.com/documentation/uikit/uiinputviewaudiofeedback), [enableInputClicksWhenVisible](https://developer.apple.com/documentation/uikit/uiinputviewaudiofeedback/enableinputclickswhenvisible)
- **[Doc] For keyboard extensions, the guide ties `playInputClick` to open access.** See section 1.
- **[Inferred] With Full Access off, `playInputClick()` from a Kabuki Keyboard plays nothing,** and so does any other audio path (`AudioServicesPlaySystemSound`, `AVAudioPlayer`). The current reference pages for `playInputClick()` and `UIInputViewAudioFeedback` don't mention extensions or open access, so this rests on the archived guide plus the current "no … speaker" line.
- **[Unverified] Whether the restriction is still enforced on iOS 18 and iOS 26,** for `playInputClick()` in particular, needs a device test (see Open questions).

### 3. Haptics (`UIFeedbackGenerator` family, Core Haptics)

- **[Doc] Feedback generator calls inform the system, and the system decides whether to play.** "Using the feedback APIs in SwiftUI and UIKit doesn't play haptics directly. Instead, it informs the system of the event. The system then determines whether to play the haptics based on the device, the app state, the amount of battery power remaining, and other factors." Haptics play only "On a device with hardware for haptic feedback", "When the app is running in the foreground", and "When the system Haptics setting is on". "The system ignores any requests that it can't fulfill." [Playing haptic feedback in your app](https://developer.apple.com/documentation/applepencil/playing-haptic-feedback-in-your-app)
- **[Doc] The concrete generators are `UIImpactFeedbackGenerator`, `UISelectionFeedbackGenerator`, `UINotificationFeedbackGenerator`, and `UICanvasFeedbackGenerator`.** Their reference pages have no extension or open-access caveats. [UIFeedbackGenerator](https://developer.apple.com/documentation/uikit/uifeedbackgenerator), [UIImpactFeedbackGenerator](https://developer.apple.com/documentation/uikit/uiimpactfeedbackgenerator)
- **[Doc] `CHHapticEngine` is "the connection to the haptic server",** and "the operating system could still override the request with system services". Its reference page doesn't mention extensions either. [CHHapticEngine](https://developer.apple.com/documentation/corehaptics/chhapticengine)
- **[Doc, by absence] Neither the current nor the archived open-access lists mention haptics.** [Configuring open access](https://developer.apple.com/documentation/uikit/configuring-open-access-for-a-custom-keyboard), [archive guide](https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/CustomKeyboard.html)
- **[Inferred] A literal reading allows haptics without Full Access.** "Speaker" and "audio" aren't the Taptic Engine. But Apple's lists describe the sandbox's intent rather than enumerating it, and the "app is running in the foreground" condition is undefined for an extension process. A keyboard is on screen, yet its host process is a different app. Either outcome is plausible.
- **[Supporting, not Apple] KeyboardKit says Full Access is needed for haptics.** Its README (v7.9.0) says: "Note that you need to enable full access to try some features, like audio and haptic feedback." [KeyboardKit README @ 7.9.0](https://github.com/KeyboardKit/KeyboardKit/blob/7.9.0/README.md). Its haptic engine is a plain wrapper over `UIImpactFeedbackGenerator`, `UISelectionFeedbackGenerator`, and `UINotificationFeedbackGenerator` with no Full Access check. [HapticFeedbackEngine.swift @ 7.9.0](https://github.com/KeyboardKit/KeyboardKit/blob/7.9.0/Sources/KeyboardKit/Feedback/HapticFeedbackEngine.swift) The README sentence is an empirical claim with no Apple citation, and it doesn't say which iOS versions it applies to.
- **[Supporting, not Apple] Forum threads give no Apple staff answer on keyboard haptics.** Thread 710483 only shows that `UIApplication.shared` is unavailable in a keyboard extension, which matters if you gate haptics on an app-delegate check. Use `CHHapticEngine.capabilitiesForHardware()` instead. [Forum 710483](https://developer.apple.com/forums/thread/710483), [capabilitiesForHardware()](https://developer.apple.com/documentation/corehaptics/chhapticengine/capabilitiesforhardware())

### 4. Do the user's Sounds & Haptics settings apply?

- **[Doc] The user-facing setting is Settings › Sounds & Haptics › Keyboard Feedback,** which lets the user "Play a click or vibration when you type on the keyboard" and "choose Sound, Haptic, or both". A separate "System Haptics" toggle covers "haptics for system controls and interactions". [iPhone User Guide: Change sounds and vibrations](https://support.apple.com/guide/iphone/change-sounds-and-vibrations-iph07c867f28/ios) (the guide currently shows iOS 26 and 27)
- **[Doc] Clicks respect the keyboard-click preference.** `playInputClick()` plays "only if the user has enabled keyboard clicks". The reference still says "Settings > Sounds", which is the older path. [playInputClick()](https://developer.apple.com/documentation/uikit/uidevice/playinputclick())
- **[Inferred] So `playInputClick()` is the only click path that follows Keyboard Feedback › Sound automatically.** A hand-rolled `AudioServicesPlaySystemSound` click would ignore it, and it also needs Full Access.
- **[Doc] Generator haptics respect "the system Haptics setting".** [Playing haptic feedback](https://developer.apple.com/documentation/applepencil/playing-haptic-feedback-in-your-app)
- **[Unverified] Whether "the system Haptics setting" means System Haptics or Keyboard Feedback › Haptic.** No Apple page ties `UIFeedbackGenerator` to Keyboard Feedback › Haptic. A keyboard that plays generator haptics could therefore buzz even when the user has turned keyboard haptics off.
- **[Unverified, no API found] A keyboard can't read either toggle.** I found no public API that reads System Haptics or Keyboard Feedback, and the only forum thread on it has no Apple answer. [Forum 128238](https://developer.apple.com/forums/thread/128238) If we offer haptics, we probably need our own setting in the containing app. A keyboard without Full Access can read it from the App Group, because it has read-only access to shared containers. [Configuring open access](https://developer.apple.com/documentation/uikit/configuring-open-access-for-a-custom-keyboard)

### 5. iOS 18 vs iOS 26

- **[Doc, by absence] No version-specific changes found.** The current open-access page, the `playInputClick()`, `UIInputViewAudioFeedback`, and `UIFeedbackGenerator` references, and the haptics article have no iOS 18- or 26-specific notes on extensions or open access.
- **[Unverified] Runtime behaviour on each version** can only be confirmed on device.

## Open questions (device test needed)

Run each test on an iOS 18 device and an iOS 26 device, with `RequestsOpenAccess = NO` and then with `YES` plus Allow Full Access on:

1. **Click:** `playInputClick()` from a `UIInputViewAudioFeedback` view in the keyboard, with Keyboard Feedback › Sound on and the ring switch on. Expected (documented): silent without Full Access.
2. **Haptics:** `UIImpactFeedbackGenerator(style: .light).impactOccurred()` (also try `init(view:)`), `UISelectionFeedbackGenerator`, and a `CHHapticEngine` transient event. This is the key unknown.
3. **Settings:** if haptics fire, do they stop when Keyboard Feedback › Haptic is off? When System Haptics is off? In Low Power Mode?
4. **Hosts:** does the haptic result differ between host apps (Notes vs. Safari vs. Messages)? This would show whether "foreground" means the host's state.
5. **App Review:** if haptics need Full Access, is "silent and still" an acceptable no-Full-Access experience? Guideline 4.4.1 only requires keyboards to "Remain functional … without requiring full access". [App Review Guidelines 4.4.1](https://developer.apple.com/app-store/review/guidelines/#keyboard-extensions)

## Implication for Keyboard Kabuki

Without Full Access, assume no key-click sound. Haptics are a maybe that must be tested before any feature or marketing copy depends on them. If haptics do work, give users an in-app toggle stored in the App Group, because the keyboard can't read the system's Keyboard Feedback › Haptic setting.
