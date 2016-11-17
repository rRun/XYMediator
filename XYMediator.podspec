#
# Be sure to run `pod lib lint XYMediator.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'XYMediator'
  s.version          = '0.0.1'
  s.summary          = 'iOS 组件式开发'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
                        组件式开发，引入了其他公共基础组件，日志，热补丁，定位，网络，等等
                       DESC

  s.homepage         = 'https://github.com/rRun/XYMediator'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'hexy' => 'hexy@cdfortis.com' }
  s.source           = { :git => 'https://github.com/rRun/XYMediator.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '7.0'
  s.frameworks = 'SystemConfiguration','MobileCoreServices','CFNetwork'
  s.libraries  = 'z'

  # s.source_files = 'XYMediator/Classes/**/*'
  
  # s.resource_bundles = {
  #   'XYMediator' => ['XYMediator/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'

  # 逻辑跳转中间件 - URL路由
  s.subspec 'XYMediatorCore' do |ss|

    ss.source_files = 'XYMediator/Classes/XYMediatorCore/**/*.{h,m}'

  end

  # 热补丁
  s.subspec 'XYPatchHelper' do |ss|

    ss.source_files = 'XYMediator/Classes/XYPatchHelper/**/*.{h,m}'

    ss.dependency 'YYCache', '~>1.0.3'
    ss.dependency 'JSPatch', '~>1.0.0'
    ss.dependency 'AFNetworking', '~> 3.1.0'

  end

  # 日志
  s.subspec 'XYLogger' do |ss|

    ss.source_files = 'XYMediator/Classes/XYLogger/**/*.{h,m}'

    ss.dependency 'CocoaLumberjack', '~>2.3.0'

  end

  # weex开发
  s.subspec 'XYWeex' do |ss|

    ss.source_files = 'XYMediator/Classes/XYWeex/**/*.{h,m}'

    ss.dependency 'weex', '~> 0.6.0'

  end

  # cordova开发
  s.subspec 'XYCordova' do |ss|

    ss.source_files = 'XYMediator/Classes/XYCordova/**/*.{h,m}'

    ss.dependency 'Cordova', '~> 4.1.1'

  end

  # 基本界面 - UI约束，UI主题,其他
  s.subspec 'XYBase' do |ss|

    ss.source_files = 'XYMediator/Classes/XYBase/**/*.{h,m}'

    ss.dependency 'LEETheme', '~> 1.0.7'
    ss.dependency 'Masonry', '~> 1.0.1'

  end

  #推送

  #定位

  #网络
  s.subspec 'XYNetwork' do |ss|

    ss.source_files = 'XYMediator/Classes/XYNetwork/**/*.{h,m}'

    ss.dependency 'XY_NetWorkClient', '~> 1.0.1'

  end

  #分享

end
