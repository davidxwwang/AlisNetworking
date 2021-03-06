#
# Be sure to run `pod lib lint AlisNetworking.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AlisNetworking'
  s.version          = '0.3.0'
  s.summary          = '阿里体育网络请求库'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/davidxwwang/AlisNetworking'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'xingwang.wxw' => 'xingwang.wxw@alibaba-inc.com' }
  s.source           = { :git => 'https://github.com/davidxwwang/AlisNetworking.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

    s.ios.deployment_target = '8.0'

    s.subspec 'AlisNetworkingBase' do |cs|
        cs.source_files = 'AlisNetworking/Classes/AlisNetworkingBase/**/*'
    end

    s.subspec 'AlisNetWorkingPlugins' do |cs|
        cs.source_files  = 'AlisNetworking/Classes/AlisNetWorkingPlugins/**/*'
        cs.dependency 'AlisNetworking/AlisNetworkingBase'
        cs.dependency 'AFNetworking'
        cs.dependency 'SDWebImage'
        #cs.dependency 'ALSCommonKit/EXtensions'
        #cs.ios.framework  = 'libz.1.1.3.tbd'
    end

    s.subspec 'AlisNetwork' do |cs|
        cs.source_files  = 'AlisNetworking/Classes/AlisNetwork/**/*'
        cs.dependency 'AlisNetworking/AlisNetworkingBase'
    end

end
