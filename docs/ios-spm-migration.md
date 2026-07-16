# iOS Swift Package Manager migration notes

This repository is on Flutter 3.44+, where plugin authors are expected to
support both Swift Package Manager (SPM) and CocoaPods for iOS.

## Current state

- The plugin now has an iOS Swift package at `ios/umspay/Package.swift`.
- The plugin currently links these iOS binaries:
  - `ios/Classes/AliSDK/AlipaySDK.framework`
  - `ios/Classes/UPPaymentControl/UPPaymentControlMini.framework`
  - `ios/Classes/UMSPosPayOnly/libUMSPosPayOnly.a`
  - CocoaPods dependency: `WechatOpenSDK-XCFramework`
- `ios/umspay.podspec` excludes simulator `arm64` globally:
  - `EXCLUDED_ARCHS[sdk=iphonesimulator*] = arm64`

## Findings from local inspection

- `WechatOpenSDK-XCFramework` already ships an
  `ios-arm64_x86_64-simulator` slice in `example/ios/Pods`.
- The simulator `arm64` warning is therefore not caused by WeChat itself. It is
  primarily caused by the plugin pod excluding simulator `arm64`, and likely by
  the local `.a` libraries not providing `arm64-simulator` builds.
- Extracted `arm64` objects from the local static libraries report
  `LC_VERSION_MIN_IPHONEOS`, which indicates `iphoneos` device slices rather
  than `iphonesimulator` slices.
- The SPM implementation that currently builds does this:
  - `AlipaySDK.framework` is repackaged into a local
    `ios/umspay/Binaries/AlipaySDK.xcframework`.
  - `WechatOpenSDK.xcframework` is copied into
    `ios/umspay/Binaries/WechatOpenSDK.xcframework`.
  - `libUMSPosPayOnly.a` remains a raw vendored static library and is linked
    from a small Objective-C shim target:
    `ios/umspay/Sources/UMSPosPayOnlyShim`.
  - `UPPaymentControlMini.framework` is repackaged as
    `ios/umspay/Binaries/UPPaymentControlMini.xcframework` for SwiftPM.
- This is enough for device builds through Swift Package Manager.
- Apple Silicon simulator support still depends on whether the vendors can
  provide `arm64-simulator` binaries for the local UMS and UnionPay libraries.
- Flutter `build ios --no-codesign --config-only` upgraded the example app to
  iOS 13.0, which matches the plugin podspec's declared deployment target.
- With `example/pubspec.yaml` explicitly setting
  `flutter.config.enable-swift-package-manager: true`, `flutter build ios
  --no-codesign` now succeeds for device builds.
- The example host app has been manually migrated to SPM-only:
  - `example/ios/Podfile` and `Podfile.lock` are removed.
  - `example/ios/Flutter/Debug.xcconfig` and `Release.xcconfig` no longer
    include Pods xcconfig files.
  - `example/ios/Runner.xcodeproj/project.pbxproj` no longer contains Pods
    frameworks or `[CP] Check Pods Manifest.lock` phases.
- On current Flutter tooling, iOS builds also auto-migrate the example host to
  the UIScene + implicit engine setup used by SwiftPM plugin registration.
  These generated changes currently touch:
  - `example/ios/Flutter/AppFrameworkInfo.plist`
  - `example/ios/Runner/AppDelegate.swift`
  - `example/ios/Runner/Info.plist`
  - `example/ios/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme`
  Reverting them is not useful because `flutter build ios` writes them back.

## What "formal SPM support" means here

For this plugin, adding SPM support is not just adding an empty
`Package.swift`. The iOS dependency graph has to become SwiftPM-resolvable.

That means:

1. The plugin needs a package layout under `ios/umspay/`, typically:
   - `ios/umspay/Package.swift`
   - `ios/umspay/Sources/umspay/...`
2. Every vendored binary used by the Swift target must be available to SwiftPM,
   either as an `.xcframework` or through a shim target that links raw static
   libraries from the package.
3. The WeChat dependency must be expressed as an SPM dependency rather than a
   CocoaPods dependency.
4. CocoaPods support must remain in place until Flutter explicitly says
   otherwise.

## Required migration work

1. Keep `ios/umspay/Package.swift` and `ios/umspay/Sources/...` as the source
   of truth for SPM.
2. Rebuild or replace the local binaries as proper vendor artifacts.
   - Best path: obtain official vendor distributions that already include both
     `iphoneos` and `iphonesimulator` slices.
   - The current branch uses a shim target for the raw `.a` libraries because
     those SDKs are not yet clean SwiftPM binary targets.
3. Remove the global simulator `arm64` exclusion from the podspec once all
   binary dependencies support Apple Silicon simulators.
4. Keep CocoaPods support working.
   - `ios/umspay.podspec` must continue to build against the same sources and
     vendored artifacts.
5. Manually migrate host apps that still have custom CocoaPods integration.
   - Flutter can add Swift package references automatically.
   - It cannot fully remove a non-standard `ios/Podfile` or pod xcconfig
     includes automatically.

## Recommended implementation order

1. Obtain updated iOS SDK artifacts from the payment vendors:
   - Alipay
   - UnionPay / UPPaymentControl
   - UMS Pos Pay
2. Verify each artifact has:
   - `ios-arm64`
   - `ios-arm64_x86_64-simulator` or equivalent simulator coverage
3. Replace the shim target with proper vendor-provided packageable binaries if
   those become available.
4. Remove old CocoaPods-only host app glue from `example/ios` after confirming
   no Pod dependencies remain.

## Validation checklist

- `flutter build ios --no-codesign --config-only`
- `flutter build ios --no-codesign`
- `flutter build ios --simulator`
- No Flutter warning about missing SPM support
- Apple Silicon simulator build currently fails because
  `ios/Classes/UMSPosPayOnly/libUMSPosPayOnly.a` links its `arm64` slice as an
  `iphoneos` binary rather than an `arm64-simulator` binary
