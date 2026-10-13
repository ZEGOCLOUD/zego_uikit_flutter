#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint zego_uikit_plugin.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'zego_uikit'
  s.version          = '2.29.4' # zego_uikit:
  s.summary          = 'A new Flutter project.'
  s.description      = <<-DESC
A new Flutter project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'zego_uikit/Sources/zego_uikit/**/*'
  s.public_header_files = 'zego_uikit/Sources/zego_uikit/include/zego_uikit/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'zego_express_engine_for_uikit'
  s.dependency 'ZegoUIKitReport', '0.2.10'
  s.static_framework = true
  s.platform = :ios, '14.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386', 'HEADER_SEARCH_PATHS' => '$(inherited) "$(PODS_TARGET_SRCROOT)/zego_uikit/Sources/zego_uikit/include/zego_uikit"' }
end
