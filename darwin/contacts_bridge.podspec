#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint contacts_bridge.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'contacts_bridge'
  s.version          = '1.0.0'
  s.summary          = 'A modern Flutter plugin for managing device contacts with support for Android, iOS, and macOS.'
  s.description      = <<-DESC
A modern Flutter plugin for managing device contacts with support for Android, iOS, and macOS. 
Features comprehensive contact operations, group management, and permission handling with clean architecture.
                       DESC
  s.homepage         = 'https://github.com/ahmtydn/contacts_bridge'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Ahmet Aydin' => 'ahmtydn@gmail.com' }
  
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  
  # Platform dependencies
  s.ios.dependency 'Flutter'
  s.osx.dependency 'FlutterMacOS'
  
  # Deployment targets
  s.ios.deployment_target = '12.0'
  s.osx.deployment_target = '10.14'
  
  # Framework requirements
  s.frameworks = 'Contacts', 'ContactsUI'
  
  # Privacy info
  s.resource_bundles = {
    'contacts_bridge_privacy' => ['Assets/PrivacyInfo.xcprivacy']
  }
end