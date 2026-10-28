# Can the app tell whether the French Kabuki Keyboard has been added?

Researched 2026-10-28 for [issue #5](https://github.com/jmlivingston/keyboard-kabuki/issues/5). Sources: Apple developer documentation, the App Extension Programming Guide (archived, but still Apple's most detailed custom-keyboard reference), the Human Interface Guidelines, and the App Review Guidelines. Developer-doc pages were read through their JSON data endpoints (`https://developer.apple.com/tutorials/data/documentation/<path>.json`) because the HTML is rendered client-side. The URLs below are the human-readable equivalents. Apple Developer Forums posts and KeyboardKit source code are used only as supporting evidence, and are labelled.

Constraints, as given: no Full Access, no private API, and the keyboard can't write to the App Group.

Each claim is tagged:

- **[Documented]**: Apple says so, with a link.
- **[Inferred]**: follows from documented facts but isn't stated.
- **[Unverified]**: plausible, but needs a device test.

## TL;DR

**No reliable, public, Full-Access-free way exists to know that *our* keyboard specifically has been added.**

- The only public API is `UITextInputMode.activeInputModes`. Its elements expose just one documented property, `primaryLanguage`. A French Kabuki Keyboard with `PrimaryLanguage = fr-FR` looks the same as Apple's French keyboard.
- The properties that *would* identify it (`identifier`, `isDisplayed`) and the `AppleKeyboards` user-defaults key are undocumented. KeyboardKit reads them through KVC, which App Review 2.5.1 rules out for us.
- The keyboard can't send a flag back. Without Full Access it can only *read* the App Group, and it can't open URLs.

**What the setup screen can do instead:**

1. Show step-by-step instructions, as the HIG recommends.
2. Deep-link with `UIApplication.openSettingsURLString`. That opens the app's own page in Settings. Apple doesn't document whether a "Keyboards" row appears there, so this needs a device test.
3. Offer a "Try it here" text field. The app can watch `primaryLanguage` change there as a *hint*, not proof.
4. Optionally use `activeInputModes` as a soft heuristic ("a French keyboard is active"). This needs privacy-manifest reason `3EC4.1`.

## Findings

### 1. `UITextInputMode.activeInputModes`: public, but can't identify our keyboard

- **[Documented]** `activeInputModes` returns "the active text-input modes", each a `UITextInputMode`. It returns an empty array "if no such instances have been set by the text input system." [activeInputModes](https://developer.apple.com/documentation/uikit/uitextinputmode/activeinputmodes)
- **[Documented]** `UITextInputMode`'s public surface is only `activeInputModes`, `primaryLanguage`, `currentInputModeDidChangeNotification`, and `init(coder:)`. It has no bundle-ID or extension property. [UITextInputMode](https://developer.apple.com/documentation/uikit/uitextinputmode)
- **[Documented]** `primaryLanguage` is "a BCP 47 language code such as 'es', 'en-US', or 'fr-CA'." [primaryLanguage](https://developer.apple.com/documentation/uikit/uitextinputmode/primarylanguage)
- **[Documented]** A custom keyboard's `PrimaryLanguage` Info.plist key is "a string representing the primary language your keyboard supports … The Settings app displays the primary language in the list of keyboards." [Creating a custom keyboard](https://developer.apple.com/documentation/uikit/creating-a-custom-keyboard)
- **[Inferred]** So a French Kabuki Keyboard declared as `fr-FR` reports the same `primaryLanguage` as Apple's French (France) keyboard. `activeInputModes` can say "some French keyboard is active", but not "ours is".
- **[Unverified]** That third-party keyboards appear in `activeInputModes` at all, and with the Info.plist `PrimaryLanguage` as their `primaryLanguage`. KeyboardKit relies on the first part (§3), and a forum post shows extension modes with an `en` primary language ([Forum 652615](https://developer.apple.com/forums/thread/652615), community post). Apple doesn't state either. Needs a device test.
- **[Documented]** `activeInputModes` is a Required Reason API (category `NSPrivacyAccessedAPICategoryActiveKeyboards`), and we must declare it in `PrivacyInfo.xcprivacy`. Reason **`3EC4.1`** fits us exactly: "Declare this reason if your app is a custom keyboard app, and you access this API category to determine the keyboards that are active on the device. Providing a systemwide custom keyboard to the user must be the primary functionality of the app. Information accessed for this reason … may not be sent off-device." [NSPrivacyAccessedAPIType](https://developer.apple.com/documentation/bundleresources/app-privacy-configuration/nsprivacyaccessedapitypes/nsprivacyaccessedapitype), [Describing use of required reason API](https://developer.apple.com/documentation/bundleresources/describing-use-of-required-reason-api)
- **[Inferred]** That reason exists because Apple expects keyboard apps to check which keyboards are active. But the *public* API it covers can't tell keyboards with the same language apart.

### 2. The keyboard can't report back to the app

- **[Documented]** Without open access, a keyboard has "read-only access to the containing app's shared containers". Its sandbox "prevents writing to the containing app's shared group containers (reading is permitted)." [Configuring open access](https://developer.apple.com/documentation/uikit/configuring-open-access-for-a-custom-keyboard)
- **[Documented]** A keyboard has "No access to file system apart from keyboard's own container." [App Extension Programming Guide: Custom Keyboard, Table 8-1](https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/CustomKeyboard.html)
- **[Documented]** `NSExtensionContext.open(_:completionHandler:)` is supported in iOS only by "the Today and iMessage app extension points". A keyboard can't open its containing app with a flag URL. [NSExtensionContext.open](https://developer.apple.com/documentation/foundation/nsextensioncontext/open(_:completionhandler:))
- **[Documented]** App Review 4.4.1: keyboards "must not … Launch other apps besides Settings" and must "Remain functional without full network access and without requiring full access." [App Review Guidelines 4.4.1](https://developer.apple.com/app-store/review/guidelines/#keyboard-extensions)
- **[Documented]** From the keyboard's side, too: "there is no API to obtain a list of enabled keyboards." [App Extension Programming Guide: Custom Keyboard](https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/CustomKeyboard.html)
- **[Unverified]** A shared Keychain access group written by the keyboard is a side channel that no Apple doc forbids for non-Full-Access keyboards. Apple doesn't document it as allowed either. It also contradicts the spirit of "no shared container" in Table 8-1. Not recommended, and it would need a device test plus a review-risk judgement.
- **[Inferred]** The only channel the keyboard *does* have is inserting text into whichever field it's typing in, including a field in our own app. The app sees the characters but can't prove which keyboard typed them.

### 3. How others do it: private API (ruled out)

- **[Supporting: third-party source]** KeyboardKit's `KeyboardStatusInspector` (v8.8.1) does it in two ways. It reads `UITextInputMode.activeInputModes` and pulls `value(forKey: "identifier")` and `value(forKey: "isDisplayed")` through KVC. It also reads `UserDefaults.standard.object(forKey: "AppleKeyboards")`. [KeyboardStatusInspector.swift](https://github.com/KeyboardKit/KeyboardKit/blob/8.8.1/Sources/KeyboardKit/Status/KeyboardStatusInspector.swift)
- **[Supporting: forum]** A developer's debug output shows the private classes `UIKeyboardInputMode` and `UIKeyboardExtensionInputMode`, with an `identifier` that is the extension's bundle ID. [Forum 652615](https://developer.apple.com/forums/thread/652615)
- **[Documented]** None of `identifier`, `isDisplayed`, or `AppleKeyboards` appears in Apple's documentation (see §1). App Review 2.5.1: "Apps may only use public APIs." [App Review Guidelines 2.5.1](https://developer.apple.com/app-store/review/guidelines/#software-requirements)
- **[Documented]** Reading `AppleKeyboards` also conflicts with the privacy manifest. The `UserDefaults` reasons (`CA92.1`, `1C8F.1`) "do not permit reading information that was written by other apps or the system." [NSPrivacyAccessedAPIType](https://developer.apple.com/documentation/bundleresources/app-privacy-configuration/nsprivacyaccessedapitypes/nsprivacyaccessedapitype)
- **[Inferred]** Both KeyboardKit techniques are out under our constraints.

### 4. Opening Settings

- **[Documented]** `UIApplication.openSettingsURLString` is "the URL string you use to deep link to your app's custom settings in the Settings app". It opens the app's settings, "if it has any." [openSettingsURLString](https://developer.apple.com/documentation/uikit/uiapplication/opensettingsurlstring)
- **[Documented]** Apple's own path for adding a third-party keyboard is: Settings › General › Keyboard › Keyboards › Add New Keyboard, then pick it from the list of third-party keyboards. [Creating a custom keyboard](https://developer.apple.com/documentation/uikit/creating-a-custom-keyboard), [App Extension Programming Guide](https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/CustomKeyboard.html)
- **[Documented]** No public URL constant targets General › Keyboard. The only Settings deep links on `UIApplication` are app-scoped (`openSettingsURLString`, `openNotificationSettingsURLString`). [openNotificationSettingsURLString](https://developer.apple.com/documentation/uikit/uiapplication/opennotificationsettingsurlstring)
- **[Inferred]** Undocumented schemes such as `App-prefs:` / `prefs:root=…` count as non-public API under 2.5.1. Don't use them.
- **[Unverified]** It is widely observed, but not documented by Apple, that the app's own Settings page shows a "Keyboards" row for apps that contain a keyboard extension, with a toggle per keyboard (and an "Allow Full Access" switch if requested). If that holds, `openSettingsURLString` gets the user one tap from enabling the French Kabuki Keyboard. **Device test needed** on the iOS versions we support.
- **[Documented]** A settings bundle's custom settings "appear in the Keyboard area in Settings, associated with your keyboard." [App Extension Programming Guide](https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/CustomKeyboard.html)
- **[Inferred]** So adding even a minimal `Settings.bundle` helps make sure the app has an entry in Settings for `openSettingsURLString` to land on.

### 5. What the setup screen can show reliably

- **[Documented]** The HIG says: "Consider providing a keyboard tutorial in your app … tell people how to choose your keyboard, activate it during text entry, use it, and switch back to the standard keyboard. Avoid displaying help content within the keyboard itself." [HIG: Virtual keyboards](https://developer.apple.com/design/human-interface-guidelines/virtual-keyboards)
- **[Documented]** `currentInputModeDidChangeNotification` "posts when the current input mode changes," and its object is a `UITextInputMode`. A responder's `textInputMode` "identifies the language and keyboard displayed when this responder is active." [currentInputModeDidChangeNotification](https://developer.apple.com/documentation/uikit/uitextinputmode/currentinputmodedidchangenotification), [UIResponder.textInputMode](https://developer.apple.com/documentation/uikit/uiresponder/textinputmode)
- **[Inferred]** Recommended setup screen:
  1. Numbered instructions, plus a button that calls `openSettingsURLString`.
  2. A "Try it here" text field. When `primaryLanguage` turns to `fr` while the user is in that field, show a soft "Looks like a French keyboard is on" message. Never show a hard "Installed ✓".
  3. A "I've added it" button so the user can mark setup as done themselves.
  4. Re-check on `sceneWillEnterForeground`. A user who removes the keyboard later stays "done", and that's acceptable.
- **[Inferred]** When the language heuristic says "no French keyboard is active", we can be sure ours isn't added. That holds only if the extension really reports `fr-FR` (see §1 Unverified). Negative results are therefore reliable; positive results are ambiguous.

## Open questions

1. **Device test:** does `activeInputModes` in the containing app include our extension, report the Info.plist `PrimaryLanguage`, and update when the user returns from Settings without relaunching the app?
2. **Device test:** does Settings › Keyboard Kabuki (via `openSettingsURLString`) show a "Keyboards" row with a toggle for each Kabuki Keyboard on iOS 18, 26, and 27? Is a `Settings.bundle` needed for the page to exist?
3. **Unique language tag:** could the French Kabuki Keyboard declare a distinguishing but valid BCP 47 tag (for example `fr-FR-x-kabuki`) that shows up verbatim in `primaryLanguage`? It would make detection near-certain with public API only. A forum user reports a custom code (`cls`) round-tripping through `primaryLanguage` ([Forum 706659](https://developer.apple.com/forums/thread/706659), community post). Risks: what Settings shows, autocorrect and lexicon language, and host apps' spell-check language. Needs a device test and a product decision.
4. **Review risk of `3EC4.1`:** is declaring `activeInputModes` worth it for a soft hint, or should the setup screen skip detection entirely and rely on instructions plus a manual "done"?
