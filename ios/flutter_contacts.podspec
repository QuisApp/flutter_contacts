Pod::Spec.new do |s|
  s.name             = 'flutter_contacts'
  s.version          = '0.0.1'
  s.summary          = 'Fast, complete contact management for Android, iOS & macOS.'
  s.description      = <<-DESC
Fast, complete contact management for Android, iOS & macOS — all fields, groups, accounts, vCards, native dialogs, listeners, SIM contacts, and number blocking.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :git => 'https://github.com/QuisApp/flutter_contacts.git', :tag => s.version.to_s }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'Tests/**/*'
  end
end
