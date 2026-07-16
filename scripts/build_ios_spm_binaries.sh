#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IOS_DIR="$ROOT_DIR/ios"
OUTPUT_DIR="$IOS_DIR/umspay/Binaries"
TMP_DIR="${TMPDIR:-/tmp}/umspay-spm-binaries"

ALIPAY_SOURCE="$IOS_DIR/Classes/AliSDK/AlipaySDK.framework"
WECHAT_SOURCE="$ROOT_DIR/example/ios/Pods/WechatOpenSDK-XCFramework/WechatOpenSDK.xcframework"

write_framework_info_plist() {
  local plist_path="$1"
  local framework_name="$2"
  cat >"$plist_path" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>en</string>
  <key>CFBundleExecutable</key>
  <string>${framework_name}</string>
  <key>CFBundleIdentifier</key>
  <string>com.jajs.umspay.${framework_name}</string>
  <key>CFBundleInfoDictionaryVersion</key>
  <string>6.0</string>
  <key>CFBundleName</key>
  <string>${framework_name}</string>
  <key>CFBundlePackageType</key>
  <string>FMWK</string>
  <key>CFBundleShortVersionString</key>
  <string>1.0</string>
  <key>CFBundleVersion</key>
  <string>1</string>
  <key>MinimumOSVersion</key>
  <string>13.0</string>
</dict>
</plist>
EOF
}

create_alipay_xcframework() {
  local temp_root="$TMP_DIR/AlipaySDK"
  local device_framework="$temp_root/device/AlipaySDK.framework"
  local simulator_framework="$temp_root/simulator/AlipaySDK.framework"

  mkdir -p "$temp_root/device" "$temp_root/simulator"
  cp -R "$ALIPAY_SOURCE" "$device_framework"
  cp -R "$ALIPAY_SOURCE" "$simulator_framework"
  lipo -thin arm64 "$ALIPAY_SOURCE/AlipaySDK" -output "$device_framework/AlipaySDK"
  lipo -thin x86_64 "$ALIPAY_SOURCE/AlipaySDK" -output "$simulator_framework/AlipaySDK"
  write_framework_info_plist "$device_framework/Info.plist" "AlipaySDK"
  write_framework_info_plist "$simulator_framework/Info.plist" "AlipaySDK"

  xcodebuild -create-xcframework \
    -framework "$device_framework" \
    -framework "$simulator_framework" \
    -output "$OUTPUT_DIR/AlipaySDK.xcframework"
}

copy_wechat_xcframework() {
  if [[ ! -d "$WECHAT_SOURCE" ]]; then
    echo "Missing WeChat xcframework source at: $WECHAT_SOURCE" >&2
    echo "Run 'flutter build ios --no-codesign --config-only' in example/ first." >&2
    exit 1
  fi

  cp -R "$WECHAT_SOURCE" "$OUTPUT_DIR/WechatOpenSDK.xcframework"
}

remove_ds_store_files() {
  find "$OUTPUT_DIR" -name '.DS_Store' -type f -delete
}

main() {
  if [[ -e "$OUTPUT_DIR" ]]; then
    echo "Output directory already exists: $OUTPUT_DIR" >&2
    echo "Remove it before regenerating SPM binaries." >&2
    exit 1
  fi

  rm -rf "$TMP_DIR"
  mkdir -p "$OUTPUT_DIR"

  create_alipay_xcframework
  copy_wechat_xcframework
  remove_ds_store_files

  echo "Generated xcframeworks in $OUTPUT_DIR"
}

main "$@"
