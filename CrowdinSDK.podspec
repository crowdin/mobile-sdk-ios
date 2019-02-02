#
# Be sure to run `pod lib lint CrowdinSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |spec|
  spec.name             = 'CrowdinSDK'
  spec.version          = '0.1.0'
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
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  spec.license          = { :type => 'MIT', :file => 'LICENSE' }
  spec.author           = { 'Serhii Londar' => 'serhii.londar@gmail.com' }
  spec.source           = { :git => 'https://github.com/Serhii Londar/CrowdinSDK.git', :tag => spec.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  spec.ios.deployment_target = '9.0'


  spec.frameworks = 'UIKit'
  spec.static_framework = true
  spec.default_subspec = 'Core'
  
  spec.subspec 'Core' do |core|
      core.source_files = 'CrowdinSDK/Classes/CrowdinSDK/**/*'
      core.resources = 'CrowdinSDK/Assets/**/*.{storyboard}'
  end
  
  spec.subspec 'FirebaseProvider' do |firebase|
      firebase.name = 'FirebaseProvider'
      firebase.dependency 'Firebase'
      firebase.dependency 'FirebaseDatabase'
      firebase.source_files = 'CrowdinSDK/Classes/Providers/Firebase/*.swift', 'CrowdinSDK/Classes/Localization/Provider/LocalizationProvider.swift'
      firebase.dependency 'CrowdinSDK/Core'
  end
end
