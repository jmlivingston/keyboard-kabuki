# Can an iOS app tint Apple's built-in keyboards?

Researched 2026-10-28 against Apple primary sources (developer documentation, the Human Interface Guidelines, App Review Guidelines, Device Management reference, and Apple Support). Apple Developer Forums threads are used only as supporting evidence and are labelled as such. Developer-doc pages were read through their JSON data endpoints (`https://developer.apple.com/tutorials/data/documentation/<path>.json`), because the HTML pages are rendered client-side. The URLs cited below are the human-readable equivalents.

> Note on versions: Apple Support's iPhone User Guide currently offers iOS 27 as the newest version, and Apple has published "New in iOS … 27" notes ([support.apple.com/en-us/149045](https://support.apple.com/en-us/149045)). The brief asked about iOS 18 and 26. iOS 27 is covered where it changes the answer, and it doesn't change it.

## TL;DR verdict

**Confirmed: no.** No public API, setting, Shortcut, or MDM payload lets a third-party app (or the user) give Apple's built-in keyboards an arbitrary background color, and nothing does it per keyboard language. Apple exposes only `keyboardAppearance` (default, light, dark, alert), and only for text fields inside your own app. The only legitimate way to get "Japanese = light red, English = blue" everywhere is a **custom keyboard extension** that replaces the system keyboard. That means rebuilding kana/romaji input and Kana–Kanji conversion yourself, and accepting that iOS swaps the stock keyboard back in for secure fields, phone pads, and apps that opt out.

---

## Findings by area

### 1. Public APIs that affect keyboard appearance

**Documented facts**

- **`UIKeyboardAppearance` has four cases: `default`, `dark`, `light`, `alert`.** The case descriptions are "default keyboard appearance for the current input method", "suitable for a dark UI look", "suitable for a light UI look", and "suitable for an alert panel". There is no color or tint value. [UIKeyboardAppearance](https://developer.apple.com/documentation/uikit/uikeyboardappearance)
- **`keyboardAppearance` is a `UITextInputTraits` property of a text object, so it only applies to fields you own.** Apple describes it as "The appearance style of the keyboard for the text object", which "lets you distinguish between the default text entry inside your application and text entry inside an alert panel." [UITextInputTraits.keyboardAppearance](https://developer.apple.com/documentation/uikit/uitextinputtraits/keyboardappearance)
- **`inputView` and `inputAccessoryView` are `UIResponder` properties that your own responders return.**
  - `inputView` "is typically used to provide a view to replace the system-supplied keyboard that's presented for UITextField and UITextView objects." [UIResponder.inputView](https://developer.apple.com/documentation/uikit/uiresponder/inputview)
  - `inputAccessoryView` attaches custom controls "to a system-supplied input view (such as the system keyboard)" for *your* responder. [UIResponder.inputAccessoryView](https://developer.apple.com/documentation/uikit/uiresponder/inputaccessoryview)
  - Both work only while one of your app's views is first responder.
- **`UIKeyboardLayoutGuide` (iOS 15+) is layout-only.** It is "A layout guide that represents the space the keyboard occupies in your app's layout". Its properties are `followsUndockedKeyboard`, `keyboardDismissPadding`, and `usesBottomSafeArea`, and none of them affect appearance. [UIKeyboardLayoutGuide](https://developer.apple.com/documentation/uikit/uikeyboardlayoutguide)
- **`UIInputView` gives your own input views the system keyboard's look.** It "is designed to match the appearance of the standard system keyboard". Its effects "are applied only when the view is attached to a responder as either an input view or input accessory view." [UIInputView](https://developer.apple.com/documentation/uikit/uiinputview)
- **`UIResponder.textInputMode` can request a specific keyboard (language) for your own responder.** It cannot request a color. [UIResponder.textInputMode](https://developer.apple.com/documentation/uikit/uiresponder/textinputmode)

**iOS 26 Liquid Glass**

- **The only new user-facing keyboard look control is a global clear-to-tinted slider.** Apple Support describes Settings > Appearance > Liquid Glass: "Drag the slider to the right to increase the tint of Liquid Glass, and to the left to make Liquid Glass more clear." It is system-wide, has no hue choice, and is not tied to the keyboard or a language. It is also disabled if Reduce Transparency or Increase Contrast is on. [Adjust iPhone display and text settings](https://support.apple.com/guide/iphone/adjust-iphone-display-and-text-settings-iphd6804774e/ios)
- **Forum evidence only (no Apple staff reply): developers find the iOS 26 system keyboard background inaccessible.**
  - A developer reports that the system keyboard has rounded corners in iOS 26 and that "the only options are a light or dark background". [Forum thread 801060](https://developer.apple.com/forums/thread/801060)

**Absence-of-API conclusion:** I searched the `UIKeyboardAppearance`, `UITextInputTraits`, `UIInputView`, `UIKeyboardLayoutGuide`, and `UIResponder` references and the iOS 26 Liquid Glass support article. I found no keyboard tint, color, or theming API in iOS 17, 18, 26, or 27. Every appearance hook above applies only inside the calling app's own process.

### 2. System-wide settings that change the keyboard's look

**Documented facts**

- **None of the display accessibility settings targets the keyboard alone, and none can be keyed to a language.** Apple Support lists Smart Invert, Classic Invert, Color Filters, Color Tint, Reduce Transparency, Increase Contrast, Differentiate Without Color, and Reduce White Point. [Use display and text size preferences](https://support.apple.com/en-us/111773), [Change display colors](https://support.apple.com/guide/iphone/change-display-colors-iph3e2e1fb0/ios)
  - **Color Tint is the closest match, but it tints the whole screen.** It lets you "change the hue of the entire display … Use the sliders to adjust your display's hue and the intensity of the effect."
  - **Reduce Transparency only makes surfaces opaque.** It turns "transparent backgrounds opaque by giving them a solid color", and that color is the system's, not one you choose.
- **These features can be toggled, but only by the user.** "Invert Colors and Color Filters can be quickly turned on or off with the Accessibility Shortcut." [111773](https://support.apple.com/en-us/111773)
- **Per-App Settings exist, but they are keyed to the app being used, not to the active keyboard.** Settings > Accessibility > Per-App Settings lets you "choose different color, text size, and motion settings for certain apps". [Per-app visual settings](https://support.apple.com/guide/iphone/customize-per-app-visual-settings-iph1f48544ab/ios)
- **No Shortcuts automation trigger relates to the onscreen keyboard or its language.**
  - The documented triggers are Time of Day, Alarm, Sleep, Arrive, Leave, CarPlay, Email, Message, Transaction, Wi-Fi, Bluetooth, Apple Watch Workout, NFC, App, Airplane Mode, Do Not Disturb, Low Power Mode, Battery Level, Charger, and Sound Recognition. [Add automations](https://support.apple.com/guide/shortcuts/add-automations-apdfbdbd7123/ios)
  - iOS 27 adds a "Keyboard ('When my keyboard is connected')" trigger. [149045](https://support.apple.com/en-us/149045) The wording indicates a *hardware* keyboard connecting, not a switch between onscreen input modes. That reading is inferred and not tested.
- **Focus can't be triggered by keyboard language either.** A Focus can "turn on automatically at a set time, location, or while using a certain app". [Set up a Focus](https://support.apple.com/guide/iphone/set-up-a-focus-iphd6288a67f/ios)

**Unverified (from memory, not confirmed against a primary page):** Shortcuts has "Set Appearance" (Dark/Light) and "Set Color Filters" actions, and Focus offers an "Appearance" (Dark Mode) system filter. Even if both exist, they still need a trigger, and none is keyed to input mode.

**Conclusion:** You can change the keyboard's look system-wide (Dark Mode, Increase Contrast, Reduce Transparency, Liquid Glass tint) or tint the whole screen (Color Tint). Nothing fires when the active keyboard language changes, so nothing can switch these per language.

### 3. Observing the active keyboard language from outside your process

**Documented facts**

- **`UITextInputMode` is described in terms of the current text input,** and the docs offer it to "determine the primary language currently being used for text input". [UITextInputMode](https://developer.apple.com/documentation/uikit/uitextinputmode)
- **`activeInputModes` returns the user's *enabled* keyboards, not the current one.** It is also a Required Reason API: it "has the potential of being misused … fingerprinting", and you must declare its use in `PrivacyInfo.xcprivacy`. [activeInputModes](https://developer.apple.com/documentation/uikit/uitextinputmode/activeinputmodes)
- **`currentInputModeDidChangeNotification` fires when the input mode changes,** and "The posting object is a UITextInputMode instance." [currentInputModeDidChangeNotification](https://developer.apple.com/documentation/uikit/uitextinputmode/currentinputmodedidchangenotification)
- **`primaryLanguage` is a BCP 47 code** such as "en-US". [primaryLanguage](https://developer.apple.com/documentation/uikit/uitextinputmode/primarylanguage)
- **Background apps are suspended.** "UIKit moves the associated scene to the background state and eventually to the suspended state." [Managing your app's life cycle](https://developer.apple.com/documentation/uikit/managing-your-app-s-life-cycle)

**Conclusion (inference from the above, not stated verbatim by Apple):** `currentInputModeDidChangeNotification` is a `NotificationCenter` notification delivered inside your own process. You only receive it while your app is running and editing text. A suspended app gets nothing, and there is no background mode or Darwin notification for input-mode changes. Even if an app could detect the change, it would still have no API to recolor the system keyboard (area 1).

### 4. MDM and configuration profiles

**Documented facts**

- **Restrictions payload keys only switch keyboard features on or off.** The keyboard-related keys are `allowAutoCorrection`, `allowContinuousPathKeyboard` (QuickPath), `allowDefinitionLookup`, `allowDictation`, `allowKeyboardShortcuts`, `allowPredictiveKeyboard`, and `allowSpellCheck`. They are now marked deprecated in favor of the declarative `com.apple.configuration.keyboard.settings` configuration. [Restrictions](https://developer.apple.com/documentation/devicemanagement/restrictions)
- **The declarative KeyboardSettings configuration also only restricts features.** "This configuration restricts keyboard features." Its keys are AllowAutoCorrection, AllowDefinitionLookup, AllowDictation, AllowMathKeyboardSuggestions, AllowPredictiveText, AllowSlideToType, AllowSpellCheck, and AllowTextReplacement (several are iOS 26.4+). [KeyboardSettings](https://developer.apple.com/documentation/devicemanagement/keyboardsettings)

**Conclusion:** No appearance, color, or theme key exists for keyboards in MDM, either in profile payloads or in Declarative Device Management. Searched: the Restrictions payload and the KeyboardSettings declaration, for "keyboard", "appearance", and "dark mode".

### 5. Fallback: a custom keyboard extension

**Documented facts**

- **A custom keyboard owns its UI completely, so background color is unrestricted.**
  - "A custom keyboard replaces the system keyboard … Your custom keyboard extension's principal class provides the view that's displayed." [Creating a custom keyboard](https://developer.apple.com/documentation/uikit/creating-a-custom-keyboard)
  - "add your keyboard's user interface to the `inputView` property" of a `UIInputViewController` subclass. [UIInputViewController](https://developer.apple.com/documentation/uikit/uiinputviewcontroller)
- **Each language can get its own keyboard and color.**
  - Apple documents adding one keyboard target per language, each with its own `PrimaryLanguage` value. [Creating a custom keyboard](https://developer.apple.com/documentation/uikit/creating-a-custom-keyboard)
  - `UIInputViewController.primaryLanguage` exists. [UIInputViewController](https://developer.apple.com/documentation/uikit/uiinputviewcontroller)
- **Minimal permissions work: no Full Access is needed to read colors chosen in the app.**
  - Without open access, a keyboard has "read-only access to the containing app's shared containers", and the system guarantees keystrokes go only to the host app. [Configuring open access](https://developer.apple.com/documentation/uikit/configuring-open-access-for-a-custom-keyboard)
  - So the containing app writes the chosen colors to an App Group, and the keyboard reads them.
  - App Review 4.4.1 requires keyboards to "Remain functional without full network access and without requiring full access", "Provide a method for progressing to the next keyboard", and "Provide keyboard input functionality". [App Review Guidelines 4.4.1](https://developer.apple.com/app-store/review/guidelines/#keyboard-extensions)
  - So a keyboard that only changes color and does no typing would be rejected; it must actually type.
- **iOS forces the system keyboard back in three documented cases:**
  - **Secure text fields:** "Secure text field entries always show the system keyboard … temporarily removing your custom keyboard."
  - **Phone pads:** fields with keyboard type `phonePad` or `namePhonePad` "show the system keyboard."
  - **Apps that opt out:** an app "can disallow the use of third-party keyboards entirely by implementing `application(_:shouldAllowExtensionPointIdentifier:)` and returning `false` … with the `com.apple.keyboard-service` identifier."
  - Sources: [Configuring a custom keyboard interface](https://developer.apple.com/documentation/uikit/configuring-a-custom-keyboard-interface), [shouldAllowExtensionPointIdentifier](https://developer.apple.com/documentation/uikit/uiapplicationdelegate/application(_:shouldallowextensionpointidentifier:)), [ExtensionPointIdentifier.keyboard](https://developer.apple.com/documentation/uikit/uiapplication/extensionpointidentifier/keyboard), [App Extension Programming Guide – Custom Keyboard](https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/CustomKeyboard.html)
  - The HIG says the same: custom keyboards work "within any app, except when editing secure text fields and phone number fields." [HIG: Virtual keyboards](https://developer.apple.com/design/human-interface-guidelines/virtual-keyboards)
- **You must rebuild the stock keyboard's features yourself.**
  - Apple lists user expectations that include "Multistage input for languages that use ideographic characters and symbols, such as Kanji (Japanese)", autocorrection, and smart quotes. [Configuring a custom keyboard interface](https://developer.apple.com/documentation/uikit/configuring-a-custom-keyboard-interface)
  - The archive guide says "there is no dedicated API for any of the features just listed". It also says custom keyboards can't read most Settings > General > Keyboard options, can't select text, can't offer inline autocorrection near the insertion point, and can't draw key pop-ups above the top edge of their view. [App Extension Programming Guide](https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/CustomKeyboard.html)
  - A custom keyboard can't host Apple's Kana–Kanji converter. `UILexicon` provides only contacts, text shortcuts, and common words. [Configuring a custom keyboard interface](https://developer.apple.com/documentation/uikit/configuring-a-custom-keyboard-interface)
- **Some system-drawn areas stay outside your control.** "On some devices, the Emoji/Globe key and Dictation key automatically appear beneath the keyboard … Your app can't affect these keys." [HIG: Virtual keyboards](https://developer.apple.com/design/human-interface-guidelines/virtual-keyboards) On Face ID iPhones, "iOS automatically shows the globe icon below your keyboard view". [Creating a custom keyboard](https://developer.apple.com/documentation/uikit/creating-a-custom-keyboard) So the strip below the keys stays system-colored.
- **iOS 26 adds more system chrome around custom keyboards (forum evidence only, no Apple confirmation):**
  - Developers report a system grey or Liquid Glass frame around custom keyboards in Liquid Glass-enabled host apps (Messages, Notes, Safari) that "the keyboard's own views cannot draw over". [Forum 800838](https://developer.apple.com/forums/thread/800838), [Forum 793686](https://developer.apple.com/forums/thread/793686)
  - The community workaround is a clear background, which works against a full-bleed custom color.

---

## Loopholes considered

| Idea | Verdict | Why |
|---|---|---|
| Set `keyboardAppearance` / `inputAccessoryView` | Fails | Only light/dark/alert, only for your app's own fields (area 1). |
| Detect language with `currentInputModeDidChangeNotification`, then flip a setting | Fails | Delivered only in-process while your app is active. No app API changes system Dark Mode or Color Tint, and no Shortcut trigger exists (areas 2–3). |
| Color Tint via the Accessibility Shortcut (triple-click), toggled by hand when switching to Japanese | "Works" only as a manual hack | Tints the *entire screen*, not the keyboard. The user has to do it, so there is nothing for an app to build. |
| Shortcuts / Focus automation that switches appearance | Fails | No input-mode trigger. The iOS 27 "keyboard is connected" trigger appears to be about hardware keyboards (unverified). |
| Per-App accessibility settings | Fails | Keyed to the app being used, not to the keyboard language. |
| MDM / configuration profile | Fails | Keyboard payloads only restrict features (area 4). |
| Liquid Glass tint slider (iOS 26) | Fails | Global clear↔tinted only, no hue choice, not per language. |
| Overlay a colored window behind or around the keyboard (e.g., Picture in Picture) | Fails | Third-party apps can't draw over other apps except in PiP, which is a user-movable video window, not a backdrop. Abusing it would likely fall under App Review 2.5.9 ("alter … native user interface elements or behaviors"). [Guidelines](https://developer.apple.com/app-store/review/guidelines/) (Inference, not tested.) |
| Custom keyboard extension | **Works**, with caveats | Full control of background color, per-language targets, no Full Access needed. Loses the stock IME, gets replaced in secure, phone-pad, and opted-out fields, and has system-colored areas (area 5). |
| Jailbreak tweaks | Out of scope | They exist and are not a legitimate App Store route. |

## Implications for the product

1. **Building it as described means building a keyboard.** "Tint Apple's keyboard" can't ship. "Keyboard Kabuki" would ship as a custom keyboard extension, or one per language, whose background color comes from the app's `UIColorPicker`-driven settings via a read-only App Group.
2. **No Full Access fits the "minimal permissions, no interest in keystrokes" goal,** and the system guarantees it (area 5). Market this explicitly.
3. **The hard part is input, not color.** For Japanese, matching the stock Kana/Romaji keyboard means writing or licensing a Kana–Kanji conversion engine and dictionary. English needs autocorrect and prediction for parity. Scope this before committing.
4. **Users will still see the stock keyboard, untinted,** in password fields, phone-number fields, and apps such as banking apps that reject third-party keyboards. Set that expectation in onboarding.
5. **On iOS 26+, design for the system frame** (Liquid Glass wrapper or grey margin plus the globe/dictation strip). The color covers the key area, not the whole bottom of the screen.
6. **A cheaper alternative product:** a guide or Shortcut that teaches the Accessibility Shortcut → Color Tint trick. It is honest about being whole-screen and manual, and it needs no app at all.

## Open questions

- Does the iOS 27 Shortcuts "When my keyboard is connected" trigger ever fire on onscreen input-mode switches? I expect it's hardware-only, but this is untested.
- Do Shortcuts actions "Set Appearance" and "Set Color Filters" exist, and with exactly what parameters (e.g., can Color Tint hue be set)? Not confirmed against a primary Apple page.
- iOS 26/27 custom keyboard frame: is there a documented way for an extension to detect a Liquid Glass host or paint the margin? There is no Apple response in the forums, so this needs on-device testing on the current release.
- Is there a licensable or open Kana–Kanji conversion engine suitable for an offline, no-Full-Access keyboard (e.g., Mozc-derived)? This is outside Apple's docs and needs separate research.
