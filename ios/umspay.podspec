#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint umspay.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'umspay'
  s.version          = '0.0.2'
  s.summary          = 'A new Flutter plugin project.'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'https://github.com/jayrao5566/flutter_ums_pay.git'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.vendored_libraries = 'Classes/**/*.a'
  s.vendored_frameworks = [
    'Classes/AliSDK/AlipaySDK.framework',
    'Classes/UPPaymentControl/UPPaymentControlMini.xcframework',
  ]
  s.source_files = 'umspay/Sources/umspay/**/*', 'umspay/Sources/UMSPosPayOnlyShim/**/*'
  s.static_framework = true
  s.dependency 'Flutter'
  s.dependency 'WechatOpenSDK-XCFramework'
  s.dependency 'SZUTDID', '~> 1.0'
  s.platform = :ios, '13.0'
  s.ios.deployment_target = '13.0'
 
  s.swift_version = '5.0'
  s.requires_arc = true
  s.user_target_xcconfig = { 'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
  }
  pod_target_xcconfig = {
      'OTHER_LDFLAGS' => '$(inherited) -ObjC -all_load',
  }

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 
    'DEFINES_MODULE' => 'YES', 
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
    'ONLY_ACTIVE_ARCH' => 'YES' 
  }

  s.resource_bundles = {'umspay_privacy' => ['umspay/Sources/umspay/PrivacyInfo.xcprivacy']}

  s.frameworks = 'SystemConfiguration', 'CoreTelephony', 'QuartzCore', 'CoreGraphics', 'CFNetwork', 'CoreMotion', 'WebKit'
  s.libraries = 'z','c++'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'umspay_privacy' => ['umspay/Sources/umspay/PrivacyInfo.xcprivacy']}
end
