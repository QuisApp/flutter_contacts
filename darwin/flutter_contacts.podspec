#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_contacts.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_contacts'
  s.version          = '0.0.1'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  # s.dependency 'Flutter'
  s.ios.dependency 'Flutter'
  s.osx.dependency 'FlutterMacOS'
  # s.platform = :ios, '8.0'
  s.ios.deployment_target = '11.0'
  s.osx.deployment_target = '10.14'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.0'
end
