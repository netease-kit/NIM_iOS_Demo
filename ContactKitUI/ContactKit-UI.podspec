#
# Be sure to run `pod lib lint ContactKitUI.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ContactKit-UI'
  s.version          = '0.1.0'
  s.summary          = 'Netease XKit'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.homepage         = 'http://netease.im'
  s.license          = { :'type' => 'Copyright', :'text' => ' Copyright 2022 Netease '}
  s.author           = 'yunxin engineering department'
  s.source           = { :git => 'ssh://git@g.hz.netease.com:22222/yunxin-app/xkit-ios.git', :tag => s.version.to_s }

  # s.source           = { :git => 'https://github.com/chenyu-home/ContactKitUI.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'contactkit-ui/Classes/**/*'
  s.resource = 'contactkit-ui/Assets/**/*'
#   s.resource_bundles = {
#     'ContactKit_UIBundle' => ['contactkit-ui/*.xcassets']
#   }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
   s.dependency 'Toast-Swift', '~> 5.0.1'
   s.dependency 'NECoreKit'
   s.dependency 'ContactKit'
   s.dependency 'CoreKit_IM'
   
   s.dependency 'Toast-Swift', '~> 5.0.1'
#   s.dependency 'TPFoundation-Swift'

end
