# What does Apple's French (France) keyboard contain?

Researched 2026-10-28 for issue #2. The goal is for the French Kabuki Keyboard to match Apple's built-in French (France) keyboard on iOS 18 and iOS 26.

Apple doesn't publish iOS keyboard layouts. The sources below are, in order of trust:

1. **Apple's shipping keyboard data.** These are the plists in the iOS 26.5 Simulator runtime (build 23F75/23F77, installed with Xcode on this Mac), under `RuntimeRoot/System/Library/TextInput/TextInput_fr.bundle/` and `RuntimeRoot/System/Library/PrivateFrameworks/KeyboardSettings.framework/`. This is Apple's own data, but it isn't public documentation and it isn't linkable. Each item gives the file path and key so it can be re-read with `plutil -p`.
2. **Apple Support and Apple Developer documentation**, linked per claim. The developer-doc pages were read through `https://developer.apple.com/tutorials/data/documentation/<path>.json`.
3. **Observation.** I booted a throwaway iPhone 17 Pro simulator on iOS 26.5 with the language set to fr-FR and the only keyboard set to `fr_FR@sw=AZERTY-French;hw=French`. I then opened a Messages compose field (`sms:` URL) and took a screenshot. I couldn't send taps, so the numbers and symbols pages and long-press popups were **not** observed in the simulator.

Labels used below: **[Doc]** means Apple documentation; **[Data]** means Apple's shipping iOS 26.5 keyboard data; **[Observed]** means seen in a screenshot (simulator or Apple Support); **[Inference]** means my reasoning; **[Unverified]** means from memory or not confirmed for that iOS version.

> **Caveat on iOS 18.** No iOS 18 runtime is installed, and Apple Support's *French* screenshots for iOS 18 and 26 show the **English QWERTY** keyboard, because Apple didn't reshoot them for the French locale. Everything marked [Data] or [Observed] (simulator) is **iOS 26.5**. iOS 18 differences are flagged where there is evidence and are otherwise open.

---

## TL;DR

- **Default layout is "AZERTY – French" (`AZERTY-French`), not plain "AZERTY".** fr_FR also offers AZERTY, QWERTY – Accents, QWERTY, and QWERTZ. [Data]
- **Letter rows (iOS 26.5, iPhone portrait, observed):**
  - `A Z E R T Y U I O P`
  - `Q S D F G H J K L M`
  - `⇧ W X C V B N ´ ⌫`
  - `123 · [space] · ⏎`
  - Emoji, globe, and microphone sit below the keyboard. The 3rd-row key after N is an **acute-accent `´` key**, not an apostrophe. Its long-press set is `´ ˋ ˆ ¨`.
- **Long-press sets** come straight from Apple's data. For example: `e` → `é è ê ë e ę ė ē`, `a` → `à â ª a æ á ä ã å ā`, `c` → `ç c ć č`, `u` → `û ù u ü ú ū`, `i` → `î ï i ì í į ī`, `o` → `ô œ º o ö ò ó õ ø ō`, `y` → `y ÿ`, `n` → `n ñ ń`. Keys on the left side open their popup to the right; keys on the right side open it to the left. [Data]
- **Numbers and symbols:**
  - The only French-specific data is currency. The primary sign is **€**, and the alternates are **$ £ ¥**. [Data]
  - The full key-by-key pages weren't observable and remain **[Unverified]**.
- **Shift:**
  - Tap for one capital. [Doc]
  - Touch Shift and slide to a letter for a capital. [Doc]
  - Double-tap for Caps Lock, which the user can turn off with "Enable Caps Lock". [Doc] [Data]
- **Space bar:**
  - Double-tapping space inserts ". ". This is the "“.” Shortcut" setting. [Doc] [Data]
  - In iOS 26.5 the space bar shows **no label** in this simulator configuration. [Observed]
  - The French label string "espace" exists in the data. [Data]
- **Return key:**
  - iOS 26 shows a **⏎ glyph** for the default return type. [Observed]
  - iOS 18 showed a text label, "return" in Apple's screenshots. For French the label string is **"retour"**. [Observed] [Data]
  - Other return types have French labels such as "envoyer", "rechercher", "accéder", "suivant", "terminé", "rejoindre", "itinéraire", "continuer", and "Appel d’urgence". [Data]
  - A custom keyboard can read the field's `returnKeyType` without reading any document text. [Doc]
- **Privacy split:**
  - These smart behaviors can be done **without reading text**: the long-press accents, Caps Lock, return-key label (`returnKeyType`), honoring `autocapitalizationType`, and a double-space-period rule driven by our *own* keystroke history.
  - These **need text around the cursor** and so are ruled out: Apple-accurate auto-capitalization after a sentence, a context-checked double-space period, autocorrection, predictions, and smart punctuation. [Doc] [Inference]

---

## Findings

### 1. Layouts offered for French (France)

- **The fr_FR input mode lists software layouts in this order: `AZERTY-French`, `AZERTY`, `QWERTY-Accents`, `QWERTY`, `QWERTZ`.** The iPad has extra layouts (`AZERTY-French`, `QWERTY-Accents`, `QWERTY-ISO`, `QWERTZ`). The default hardware layout is "French" (USB country 8). [Data: `TextInput_fr.bundle/InputMode_fr.plist` → `UIKeyboardSupportedInputModes.fr_FR.SWLayouts`]
- **The first entry is the default.** When the system adds the French keyboard, its identifier is `fr_FR@sw=AZERTY-French;hw=French`, and that's the identifier the simulator used. [Data] [Inference]
- **Settings shows these layouts as "AZERTY – French" and "AZERTY".** [Data: `KeyboardSettings.framework/en.lproj/KeyboardLayouts.strings`]
- **Apple documents that the user can pick an alternative layout** under Settings > General > Keyboard > Keyboards > (language). [Doc: [Add or change keyboards on iPhone](https://support.apple.com/guide/iphone/add-or-change-keyboards-iph73b71eb/26/ios/26)]
- **The fr_FR mode also declares these features:**
  - prediction (`UIKeyboardEnablePrediction`)
  - inline completion
  - a word n-gram model
  - multilingual typing
  - Slide to Type (`KeyboardCPEnabled`)
  - a French feature-specialization class (`TIKeyboardFeatureSpecialization_fr`)

  [Data: same file]

### 2. Letter rows

**[Observed]** iOS 26.5 Simulator, iPhone 17 Pro, portrait, Messages body field, light mode, with only the French keyboard enabled:

| Row | Keys |
|---|---|
| 1 | A Z E R T Y U I O P |
| 2 | Q S D F G H J K L M |
| 3 | ⇧ · W X C V B N **´** · ⌫ |
| 4 | 123 · space (no visible label) · ⏎ |
| Below the keys | Microphone (dictation) on the right. Emoji or globe on the left appears only when another keyboard (including Emoji) is enabled. The earlier run with English also enabled showed 🌐 there. |

- **The keycaps were shown in uppercase with Shift active when the field was empty.** That is auto-capitalization at the start of the field.
- **The key after N shows `´` (U+00B4 ACUTE ACCENT).** This matches Apple's data, which has a long-press set for that key: `Roman-Accent-´` = `´ ˋ ˆ ¨`. [Data: `Keyboard-fr.plist`]
  - **[Unverified]** whether tapping `´` inserts a spacing `´` or acts as a dead key that combines with the next vowel. This needs a tap test on a device.
  - **[Unverified]** where the apostrophe lives on the French layout. It isn't on the letter page in iOS 26.5. It's presumably on the numbers page (`'`), and the `Roman-Accent-.'` set (`" … ’ ‘ \``) suggests an apostrophe-bearing key somewhere, possibly on iPad.
- **iOS 18 [Unverified]:** I couldn't observe iOS 18 French. Apple Support's iOS 18 screenshots are English QWERTY, and they show a **text** return key ("return") and a space bar labelled "space" ([Type with the onscreen keyboard, fr-fr iOS 18](https://support.apple.com/fr-fr/guide/iphone/iph3c50f96e/18.0/ios/18.0)). French iOS 18 would therefore be expected to show "espace" and "retour". [Inference from `UI-Space`/`UI-Return` data]

### 3. Long-press accent sets

**[Data]** `TextInput_fr.bundle/Keyboard-fr.plist`, keys `Roman-Accent-<letter>`. These are the exact strings Apple ships for French on iOS 26.5, space-separated, in order. Uppercase sets mirror lowercase (for example, `É È Ê Ë E Ę Ė Ē`).

| Key | Popup contents, in order | `Direction` |
|---|---|---|
| e | é è ê ë e ę ė ē | right |
| a | à â ª a æ á ä ã å ā | right |
| c | ç c ć č | right |
| u | û ù u ü ú ū | left |
| i | î ï i ì í į ī | left |
| o | ô œ º o ö ò ó õ ø ō | left |
| y | y ÿ | left |
| n | n ñ ń | left |
| ´ | ´ ˋ ˆ ¨ | left |
| ˆ / ˋ (on other pages or layouts) | ˆ ´ ˋ ¨ / ˋ ´ ˆ ¨ | left |
| " | » « ” “ „ " | left |
| . | . · | left |
| .' | " … ’ ‘ ` | left |
| ,? | - ¿ | left |

- **Other letters (z r t p q s d f g h j k l m w x v b) have no French long-press set.**
- **French puts the most common French accent first and the base letter later:** for example `é` first on e, `à` on a, and `ç` on c. English, by contrast, starts with the base letter: `e è é ê ë ě ẽ ē ė ę`. [Data: `TextInput_en.bundle/Keyboard-en.plist`]
- **The French plist also has `Flick-Accent-e` → `é`** (and `É`) with `direction: 0`. This is probably a flick or swipe-down shortcut used on iPad's flick keys **[Inference, Unverified]**.

**Where the popup sits (which key it's centered on)**

- **[Inference] `Direction` is the side the popup grows toward.**
  - Keys on the left half of the AZERTY keyboard (a, e, c) grow `right`.
  - Keys on the right half (u, i, o, y, n, and ´ in the 3rd row) grow `left`.
- **[Observed] iOS 26 lays the popup out in data order, starting at the pressed key.** The iOS 26 Apple Support screenshot of the *English* e-key shows `e è é ê ë ě ẽ ē ė ę` left to right. That exactly matches the English data order with Direction = right, with `é` highlighted. [Screenshot in [fr-fr iOS 26 guide](https://support.apple.com/fr-fr/guide/iphone/iph3c50f96e/26/ios/26), image `68c87b27…png`]
- **[Observed] iOS 18 lays the popup out differently.** The iOS 18 screenshot of the same English e-key shows `ë é [e] è ê ě ẽ ē ė ę`, with the base `e` sitting over the key. [Screenshot in [fr-fr iOS 18 guide](https://support.apple.com/fr-fr/guide/iphone/iph3c50f96e/18.0/ios/18.0), image `2c2955c4…png`]
  - **[Inference]** That ordering fits the same data placed alternately outward around the key (`e` at the key, `è` right, `é` left, `ê` right, `ë` left), with the rest flowing in the `Direction`.
  - **[Unverified]** how iOS 18 places the French e-popup (`é è ê ë e …`, where the base is 5th). Applying the same rule would give `ë è é ê e? …`. This must be observed on iOS 18.
- **[Doc] Apple documents the interaction itself:** "touch and hold the letter, number, or symbol related to the character … then slide your finger and release it on the option you want." [Type with the onscreen keyboard on iPhone](https://support.apple.com/guide/iphone/type-with-the-onscreen-keyboard-iph3c50f96e/ios)

### 4. Numbers and symbols pages

- **[Doc]** The keys are "Numbers" (123) and "Symbols" (#+=). [Type with the onscreen keyboard on iPhone](https://support.apple.com/guide/iphone/type-with-the-onscreen-keyboard-iph3c50f96e/ios)
- **[Data] `Keyboard-fr_FR.plist`:**
  - `UI-PrimaryCurrencySign` = **€**
  - `UI-AlternateCurrencySign-1/2/3` = **$ £ ¥**
  - `UI-Numbers` = "123", `UI-NumbersSymbols` = ".?123", `UI-ABC` = "ABC"
- **[Inference]** The primary currency takes the slot that `$` occupies on the US numbers page, and the alternates take the currency slots on the symbols page.
- **[Unverified, from memory, not observed]** Expected iPhone pages for fr_FR:
  - Numbers:
    - `1 2 3 4 5 6 7 8 9 0`
    - `- / : ; ( ) € & @ "`
    - `#+= . , ? ! ' ⌫`
  - Symbols:
    - `[ ] { } # % ^ * + =`
    - `_ \ | ~ < > $ £ ¥ •`
    - `123 . , ? ! ' ⌫`
  - Both pages share the bottom row `ABC · space · ⏎`.
  - Long-presses on these pages (for example `-` → `– — •`, `0` → `°`, `€` → other currencies, `"` → `» « ” “ „`) are also unverified, apart from the `"`, `.`, and `,?` sets in the table above.

### 5. Shift and Caps Lock

- **[Doc] Shift behavior:**
  - Tap Shift for a capital, or touch Shift and slide to a letter.
  - Double-tap Shift to turn on Caps Lock.

  [Type with the onscreen keyboard on iPhone](https://support.apple.com/guide/iphone/type-with-the-onscreen-keyboard-iph3c50f96e/ios); French wording: "Touchez deux fois la touche Maj" [fr-fr iOS 26](https://support.apple.com/fr-fr/guide/iphone/iph3c50f96e/26/ios/26)
- **[Data] Settings has these toggles:**
  - "Enable Caps Lock"
  - "Auto-Capitalization"
  - "Character Preview" (the key magnifier, `KEYBOARD_ALLOW_PADDLE`)

  [Data: `KeyboardSettings.framework/en.lproj/Keyboard~iphone.strings`]
- **[Observed]** The iOS 26 Shift key is a filled arrow when active, and keycaps switch to uppercase. In iOS 26 the letter keycaps are drawn **uppercase while shifted**, and the Apple Support screenshots show lowercase when not shifted.
- **[Unverified]** These aren't documented: the double-tap timing window, whether Shift auto-releases after one letter, the Caps Lock glyph (⇪ with an underline), and whether a shifted long-press shows the uppercase set.

### 6. Smart behaviors, and which ones read text

**What Apple documents**

- **Double-tapping space inserts a period and a space.**
  - "Double tapping the space bar will insert a period followed by a space." [Data: `PERIOD_SHORTCUT_DESCRIPTION`]
  - Apple Support: "Quickly end a sentence with a period and a space: Double-tap the Space bar." [Doc](https://support.apple.com/guide/iphone/type-with-the-onscreen-keyboard-iph3c50f96e/ios)
- **Apple lists the behaviors users expect from a custom keyboard:**
  - autocorrection and suggestion
  - automatic capitalization
  - automatic period upon double space
  - smart quotes
  - Caps Lock support
  - layout chosen from the keyboard-type trait

  [Configuring a custom keyboard interface](https://developer.apple.com/documentation/uikit/configuring-a-custom-keyboard-interface)
- **The field tells the keyboard *when* to auto-shift through `autocapitalizationType`**, which is none, words, sentences, or allCharacters. This is a trait, not document text. [UITextInputTraits.autocapitalizationType](https://developer.apple.com/documentation/uikit/uitextinputtraits/autocapitalizationtype), [UITextAutocapitalizationType](https://developer.apple.com/documentation/uikit/uitextautocapitalizationtype)
- **Reading surrounding text is what `documentContextBeforeInput` is for.** It is "Textual context before the insertion point". Apple says the proxy is used to "get surrounding textual context in order to support things like autocorrect or autocomplete". [documentContextBeforeInput](https://developer.apple.com/documentation/uikit/uitextdocumentproxy/documentcontextbeforeinput), [Creating a custom keyboard](https://developer.apple.com/documentation/uikit/creating-a-custom-keyboard)

**Which behaviors fit the privacy rule (never read document text, no Full Access)**

| Behavior | Can match without reading text? |
|---|---|
| Long-press accents, Caps Lock, Shift and slide | **Yes.** These are pure keyboard state. |
| Return-key label | **Yes.** Read `textDocumentProxy.returnKeyType`, which is a trait. |
| Auto-shift at the start of an empty field or after *our own* ". " | **Partly** [Inference]. We can honor `autocapitalizationType` and track what we ourselves inserted since the keyboard appeared. We can't know where the cursor is after the user moves it, or what text was already there. `hasText` reveals only whether the field is non-empty ([UIKeyInput.hasText](https://developer.apple.com/documentation/uikit/uikeyinput/hastext)). Whether `hasText` counts as reading text is a policy call. |
| Double-space → ". " | **Partly** [Inference]. If our last two inserted characters were a letter then a space, delete the space and insert ". ". That works from our own keystroke log. Apple's version presumably checks the real preceding character. Without context, ours will be wrong after cursor moves and in pre-filled text. |
| Apple-accurate sentence auto-capitalization, autocorrection, predictions, inline completion, Smart Punctuation, Check Spelling | **No.** These need `documentContextBeforeInput`/`AfterInput` and are ruled out. Predictions and corrections also rely on Apple's French language model ([Data] `UIKeyboardEnablePrediction`, `UIKeyboardHasWordNgramModel`). |
| Slide to Type (QuickPath) | Doesn't need context, but needs a word model. It's out of scope for us [Inference]. |

### 7. Return key label

- **[Doc] The label depends on the field's `returnKeyType`.**
  - Setting `returnKeyType` "changes the visible title of the Return key". [returnKeyType](https://developer.apple.com/documentation/uikit/uitextinputtraits/returnkeytype)
  - The available types are default, go, google, join, next, route, search, send, yahoo, done, emergencyCall, and continue. [UIReturnKeyType](https://developer.apple.com/documentation/uikit/uireturnkeytype)
- **[Data] French labels** (`Keyboard-fr.plist`):

  | Return type | French label |
  |---|---|
  | default | retour |
  | go | accéder |
  | next | suivant |
  | done | terminé |
  | send | envoyer |
  | search | rechercher |
  | join | rejoindre |
  | route | itinéraire |
  | continue | continuer |
  | emergencyCall | "Appel d’urgence" (two lines) |

  Google and Yahoo have no French string here **[Unverified]**; they presumably show the brand name or "rechercher".
- **[Observed] iOS 26 shows the default return key as a ⏎ glyph, not "retour".** This was seen in the simulator and in the iOS 26 Apple Support screenshot.
- **[Observed] iOS 18 showed text.** The iOS 18 Apple Support screenshot shows "return" on the English keyboard, which implies "retour" on French.
- **[Unverified]** Whether iOS 26 still shows text for non-default types (envoyer, rechercher…). In Messages, the send button sits in the text field, and the return key showed ⏎.
- **[Doc] `enablesReturnKeyAutomatically` disables Return while the field is empty.** A custom keyboard can mirror this with `hasText`, with the same policy caveat as in section 6. [enablesReturnKeyAutomatically](https://developer.apple.com/documentation/uikit/uitextinputtraits/enablesreturnkeyautomatically)
- **[Data] The French ".fr" top-level-domain key offers `.fr .com .org .edu .eu`** on URL and email keyboard types. [Data: `Keyboard-fr_FR.plist` → `UI-TopLevelDomain`]

---

## Open questions

1. **iOS 18 French, observed.** Needs an iOS 18 device or simulator runtime. What is on the 3rd row (`´` or `'`)? What do the space and return labels say? How is the e-popup arranged around the key?
2. **Numbers and symbols pages, key by key, plus their long-presses.** These need a tap-capable observation (a device, or a simulator driven by hand or with XCUITest). Alternatively, decode `TextInputUI.framework/KBLayouts_iPhone.dat`, a proprietary binary that contains `iPhone-Portrait-AZERTY-French*` keyplanes.
3. **What does the `´` key insert when tapped?** Is it a spacing `´` or a dead key that combines with the next vowel? And where is the apostrophe on the French layout?
4. **Popup geometry in iOS 26 for left-growing keys** (u, i, o, y, n): does the popup run right-to-left from the key, with the first item nearest the key?
5. **Policy decision:** Do `hasText` and `returnKeyType`/`autocapitalizationType` count as "reading document text"? They are traits or booleans, not text, but this should be stated explicitly in the privacy rule.
6. **Does iOS 26 still show text labels** for send, search, go, and similar return types, or always a glyph?
