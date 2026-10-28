# Can a free Apple developer account run the app and keyboard with a shared App Group?

Researched 2026-10-28 for issue #4, using Apple primary sources: the Apple Developer membership comparison page, the "Supported capabilities (iOS)" reference, Xcode documentation, and UIKit documentation. One Apple Developer Forums answer from an Apple DTS engineer is used as supporting evidence and is labelled as such.

Some pages render their tables and articles client-side. For those, the raw HTML table cells and the documentation JSON endpoints (`https://developer.apple.com/tutorials/data/documentation/<path>.json`) were read directly. The URLs cited below are the human-readable pages.

Labels:
- **[Doc]**: stated by Apple.
- **[Inference]**: follows from documented facts but isn't stated anywhere.
- **[Unverified]**: not confirmed. Needs a device test.

## TL;DR

**Yes, per Apple's own documentation.** A free Apple Account (an Xcode "Personal Team") can build the containing app plus the Kabuki Keyboard extension(s), install them on the user's own iPhone, and give them a shared App Group.

- In Apple's "Supported capabilities (iOS)" table, App groups is checked for the no-cost "Apple Developer" tier as well as for the paid programs.
- Xcode can create the `group.` identifier itself.
- No paid membership is needed until App Store or TestFlight work.

The limits that matter on the free tier:

- **The 7-day cycle.** Provisioning profiles, App IDs, and device registrations all expire after 7 days, so the app has to be rebuilt and reinstalled from Xcode each week.
- **10 App IDs.** The app and each Kabuki Keyboard each use their own App ID.
- **3 apps per device.**
- **Developer Mode** must be on.

Since App Groups are free, no workaround is needed. The fallback alternatives are noted below anyway.

## Findings

### 1. App Groups is available without a paid membership

- **[Doc]** The capability table's intro says: "The capabilities available to an iOS provisioning profile depend on your program membership." It has three columns:
  - **ADP**: the paid Apple Developer Program.
  - **ADEP**: the paid Enterprise program.
  - **Apple Developer**: "Apple Account holders who have agreed to the Apple Developer Agreement … No cost is associated with this agreement and developers can't distribute apps."

  The **App groups** row has a check in all three columns, including Apple Developer. [Supported capabilities (iOS)](https://developer.apple.com/help/account/reference/supported-capabilities-ios)
- **[Doc]** In the same table, **Keychain sharing**, **Background modes**, **Data protection**, HealthKit, HomeKit, and Maps are also free. All **iCloud** capabilities (CloudKit, iCloud documents, and key-value storage), **Push notifications**, Sign in with Apple, and In-App Purchase are paid only. [Supported capabilities (iOS)](https://developer.apple.com/help/account/reference/supported-capabilities-ios)
- **[Doc]** Xcode only offers the capabilities your membership allows: "The Capabilities library displays only the capabilities available to the target platform and your program membership." [Adding capabilities to your app](https://developer.apple.com/documentation/xcode/adding-capabilities-to-your-app)
- **[Doc]** A group can be created from inside Xcode: "Click the Add button (+) below the App Groups list. Enter a container ID … A container ID must begin with `group.`" Apple also says: "Alternatively, you can create app groups when you enable app groups in Xcode." [Configuring app groups](https://developer.apple.com/documentation/xcode/configuring-app-groups), [Register an app group](https://developer.apple.com/help/account/identifiers/register-an-app-group)
  - This matters because the free tier has no access to the Certificates, Identifiers & Profiles web portal (see section 2).
- **[Doc]** App groups let "an app extension … and its host app" share data, through `UserDefaults(suiteName:)` or `containerURL(forSecurityApplicationGroupIdentifier:)`. [Configuring app groups](https://developer.apple.com/documentation/xcode/configuring-app-groups)
- **[Doc]** A keyboard without Full Access gets "read-only access to the containing app's shared containers". This matches the design in `system-keyboard-tinting.md`. [Configuring open access for a custom keyboard](https://developer.apple.com/documentation/uikit/configuring-open-access-for-a-custom-keyboard)
- **[Inference]** The "Apple Developer" column of the capabilities table and the "Registered for free" column of the membership comparison describe the same no-cost tier that Xcode calls a Personal Team. Neither page uses the phrase "Personal Team" alongside the table. The comparison page does say that an account without a program membership shows as a "Personal Team" in Xcode. [Compare memberships](https://developer.apple.com/support/compare-memberships/)

### 2. Free-tier (Personal Team) limits

From [Compare memberships](https://developer.apple.com/support/compare-memberships/):

- **[Doc]** "If your account is not associated with a developer program membership, Xcode will indicate it's a Personal Team. Your account's App IDs, devices, certificates, and provisioning profiles are managed directly in Xcode, and you'll be required to reprovision your apps to a device periodically."
- **[Doc]** "You can register up to 10 App IDs, which expire after 7 days."
- **[Doc]** "You can register up to 3 devices, which expire after 7 days."
- **[Doc]** "You can install up to 3 apps per device. Provisioning profiles that enable apps to be installed on a device will expire 7 days from issuance. You'll need to rebuild and reinstall your app to your device after expiration."
- **[Doc]** In the comparison table, "On-device testing using Xcode" is checked for "Registered for free". "Certificates, Identifiers & Profiles", "App Store Connect", "TestFlight", and "Xcode Cloud" are not.
- **[Doc]** iOS requires Developer Mode to run apps from Xcode: "Enable Developer Mode on a device to run your app on the device through Xcode." [Enabling Developer Mode on a device](https://developer.apple.com/documentation/xcode/enabling-developer-mode-on-a-device)
- **[Doc]** The device-run steps accept either kind of account: "sign in with your Apple Developer Program or personal Apple Account in Xcode". [Running your app on simulated or physical devices](https://developer.apple.com/documentation/xcode/running-your-app-on-simulated-or-physical-devices)

### 3. How the App ID budget applies to Kabuki Keyboards

- **[Doc]** Apple suggests one keyboard target per language: "If you support multiple languages that require different keyboard layout or functionality, repeat the steps above to add additional custom keyboard targets for each language. Set the `PrimaryLanguage` value accordingly." [Creating a custom keyboard](https://developer.apple.com/documentation/uikit/creating-a-custom-keyboard)
- **[Doc]** An explicit App ID "contains the full path of a bundle ID". [Glossary: App ID](https://developer.apple.com/help/glossary/app-id)
- **[Forum, Apple DTS]** "An app extension has a different bundle ID than its containing app, and hence a different App ID. Each unique App ID needs a profile to authorise it to run." [Apple Developer Forums 750309](https://developer.apple.com/forums/thread/750309)
- **[Inference]** One app plus *N* Kabuki Keyboards uses 1 + *N* App IDs. With a limit of 10 App IDs per rolling 7 days, the free tier allows up to 9 Kabuki Keyboards, minus any App IDs used by other projects that week.
  - Changing bundle IDs while experimenting uses up the budget faster.
- **[Inference]** The "3 apps per device" limit counts the containing app, and its keyboard extensions ship inside its bundle. Apple doesn't say whether the extensions count separately. See the open questions.

### 4. What the 7-day expiry means for a keyboard

- **[Inference]** The keyboard extension is signed by a development profile, so it expires with the app. After 7 days, neither the app nor the Kabuki Keyboards will launch until they are rebuilt from Xcode.
  - For a keyboard, that likely means iOS skips it or falls back to another keyboard.
- **[Unverified]** Whether a reinstall over an expired build keeps the App Group container, and so keeps the saved Language Tints. Apple's container docs don't address re-signing.

### 5. Alternatives if an App Group were unavailable (not needed, recorded for completeness)

The capability table makes App Groups free, so these are fallbacks only.

- **[Doc]** A keyboard without Full Access has "No access to the file system apart from the keyboard's own sandbox container, and read-only access to the containing app's shared containers". The app's own `UserDefaults.standard` and sandbox are therefore not reachable from the keyboard. [Configuring open access for a custom keyboard](https://developer.apple.com/documentation/uikit/configuring-open-access-for-a-custom-keyboard)
- **[Doc]** Keychain sharing is also free in the capability table. Apple also says that an app group identifier starting with `group.` can serve as a keychain access group. [Supported capabilities (iOS)](https://developer.apple.com/help/account/reference/supported-capabilities-ios), [Configuring app groups](https://developer.apple.com/documentation/xcode/configuring-app-groups)
  - **[Unverified]** Whether a keyboard *without* Full Access can read a shared keychain item. The open-access page doesn't mention the keychain.
- **[Doc]** iCloud key-value storage is paid only, and non-open-access keyboards can't "participate directly or indirectly in iCloud". [Supported capabilities (iOS)](https://developer.apple.com/help/account/reference/supported-capabilities-ios), [Configuring open access](https://developer.apple.com/documentation/uikit/configuring-open-access-for-a-custom-keyboard)
- **[Inference]** The only option needing no entitlement is to compile the Language Tint into the keyboard bundle, for example in its `Info.plist` or as a constant, and rebuild to change it. That defeats an in-app color picker, but it works for a personal build.

## Open questions

- **Device test:** add the App Groups capability with a Personal Team in current Xcode, then confirm two things:
  - the `group.` container appears and the keyboard reads it without Full Access;
  - no "requires a paid membership" signing error appears.

  The capability table says this works. It hasn't been tried.
- Does each keyboard extension count toward the "3 apps per device" limit, or only the containing app?
- Does the App Group container, and so the saved Language Tints, survive a reinstall after the 7-day profile expiry? Does it survive deleting the app?
- Does an App Group registered under a Personal Team carry over when the project later moves to a paid team? Group IDs are unique per registration, so expect to re-create it under the paid team. **[Inference]**
- Can a non-Full-Access keyboard read a shared keychain item? This only matters as a fallback.
