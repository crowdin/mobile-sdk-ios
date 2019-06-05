#
# Be sure to run `pod lib lint CrowdinSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |spec|
  spec.name             = 'CrowdinSDK'
  spec.version          = '0.0.5'
  spec.summary          = 'A short description of CrowdinSDK.'
  
  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  
  spec.description      = <<-DESC
  TODO: Add long description of the pod here.
  DESC
  
  spec.homepage         = 'https://github.com/Serhii Londar/CrowdinSDK'
  spec.license          = { :type => 'MIT', :file => 'LICENSE' }
  spec.author           = { 'Serhii Londar' => 'serhii.londar@gmail.com' }
  spec.source           = { :git => 'https://github.com/Serhii Londar/CrowdinSDK.git', :tag => spec.version.to_s }
  spec.social_media_url    = 'https://twitter.com/serhii_londar'
  
  spec.ios.deployment_target = '9.0'
  
  
  spec.frameworks = 'UIKit'
  spec.static_framework = true
  spec.swift_version = '4.2'
  spec.default_subspecs = 'Core', 'CrowdinProvider'
  
  spec.subspec 'Core' do |core|
    core.source_files = 'CrowdinSDK/Classes/CrowdinSDK/**/*'
    core.dependency 'Starscream'
  end
  
  spec.subspec 'FirebaseProvider' do |provider|
    provider.name = 'FirebaseProvider'
    provider.dependency 'Firebase'
    provider.dependency 'FirebaseDatabase'
    provider.source_files = 'CrowdinSDK/Classes/Providers/Firebase/**/*'
    provider.dependency 'CrowdinSDK/Core'
  end
  
  spec.subspec 'CrowdinProvider' do |provider|
    provider.name = 'CrowdinProvider'
    provider.source_files = 'CrowdinSDK/Classes/Providers/Crowdin/**/*.swift'
    provider.dependency 'CrowdinSDK/Core'
    provider.dependency 'CrowdinSDK/CrowdinAPI'
  end
  
  spec.subspec 'CrowdinAPI' do |subspec|
    subspec.name = 'CrowdinAPI'
    subspec.source_files = 'CrowdinSDK/Classes/CrowdinAPI/**/*'
    subspec.resource_bundle = { 'CrowdinSDKLogin' => 'CrowdinSDK/Assets/Login/CrowdinLoginVC.storyboard'}
  end
  
  spec.subspec 'MappingManager' do |mapping|
      mapping.name = 'MappingManager'
      mapping.source_files = 'CrowdinSDK/Classes/MappingManager/*.swift'
      mapping.dependency 'CrowdinSDK/Core'
      mapping.dependency 'CrowdinSDK/CrowdinAPI'
  end
  
  spec.subspec 'Screenshots' do |feature|
    feature.name = 'Screenshots'
    feature.source_files = 'CrowdinSDK/Classes/Features/ScreenshotFeature/**/*.swift'
    feature.dependency 'CrowdinSDK/Core'
    feature.dependency 'CrowdinSDK/CrowdinAPI'
    feature.dependency 'CrowdinSDK/Login'
    feature.dependency 'CrowdinSDK/MappingManager'
  end
  
  spec.subspec 'RealtimeUpdate' do |feature|
    feature.name = 'RealtimeUpdate'
    feature.source_files = 'CrowdinSDK/Classes/Features/RealtimeUpdateFeature/**/*.swift'
    feature.dependency 'CrowdinSDK/Core'
    feature.dependency 'CrowdinSDK/CrowdinAPI'
    feature.dependency 'CrowdinSDK/MappingManager'
  end
  
  spec.subspec 'RefreshLocalization' do |feature|
    feature.name = 'RefreshLocalization'
    feature.source_files = 'CrowdinSDK/Classes/Features/RefreshLocalizationFeature/**/*.swift'
    feature.dependency 'CrowdinSDK/Core'
  end
  
  spec.subspec 'Login' do |feature|
    feature.name = 'Login'
    feature.source_files = 'CrowdinSDK/Classes/Features/LoginFeature/**/*.swift'
    feature.dependency 'CrowdinSDK/CrowdinAPI'
  end
  
  
  spec.subspec 'IntervalUpdate' do |feature|
    feature.name = 'IntervalUpdate'
    feature.source_files = 'CrowdinSDK/Classes/Features/IntervalUpdateFeature/**/*.swift'
    feature.dependency 'CrowdinSDK/CrowdinAPI'
  end
  
  spec.subspec 'Settings' do |settings|
    settings.name = 'Settings'
    settings.source_files = 'CrowdinSDK/Classes/Settings/**/*.swift'
    settings.resource_bundle = { 'CrowdinSDK' => 'CrowdinSDK/Assets/Settings/*.{storyboard,xib,xcassets}'}
    settings.dependency 'CrowdinSDK/Screenshots'
    settings.dependency 'CrowdinSDK/RealtimeUpdate'
    settings.dependency 'CrowdinSDK/RefreshLocalization'
    settings.dependency 'CrowdinSDK/IntervalUpdate'
  end
end
