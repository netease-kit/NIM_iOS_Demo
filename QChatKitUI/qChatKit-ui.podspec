#
# Be sure to run `pod lib lint QChatKit-UI.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'QChatKit-UI'
  s.version          = '0.1.0'
  s.summary          = 'Netease XKit'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC
  s.homepage         = 'http://netease.im'
  s.license          = { :'type' => 'Copyright', :'text' => ' Copyright 2022 Netease '}
  s.author           = 'yunxin engineering department'
  s.source           = { :git => 'ssh://git@g.hz.netease.com:22222/yunxin-app/xkit-ios.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.source_files = 'QChatKit-UI/Classes/**/*'
  
  s.resource_bundles = {
    'QChatKit-UI' => ['QChatKit-UI/Assets/*.png']
  }
  
  s.resource = 'QChatKit-UI/Assets/**/*'
  s.dependency 'ContactKit'
  s.dependency 'CoreKit_IM'
  s.dependency 'NECoreKit'
  #FIXME: 后期需要布置路由，去除依赖
  s.dependency 'ContactKit-UI'
  
  s.dependency 'Toast-Swift', '~> 5.0.1'
  s.dependency 'IQKeyboardManagerSwift','6.5.9'
  s.dependency 'QChatKit'
  s.dependency 'SDWebImage'
  
  s.dependency 'MJRefresh','3.7.5'
#  s.dependency 'SDWebImageFLPlugin'
  s.dependency 'SDWebImageWebPCoder', '~> 0.8.4'
  s.dependency 'SDWebImageSVGKitPlugin', '~> 1.3.0'

end
