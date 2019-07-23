#
# Be sure to run `pod lib lint XTModuleBLEMF1Card.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'XTModuleBLEMF1Card'
  s.version          = '1.0.1'
  s.summary          = 'XTModuleBLEMF1Card.描述'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!11

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/leblanc-zx/XTModuleBLEMF1Card'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'leblanc-zx' => '351706354@qq.com' }
  s.source           = { :git => 'https://github.com/leblanc-zx/XTModuleBLEMF1Card.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  #s.source_files = 'XTModuleBLEMF1Card/*.{h,m}'

  # 配置子目录

  s.subspec 'Models' do |models|
  models.source_files = 'XTModuleBLEMF1Card/Models/*'
  end

  s.subspec 'BLEMF1CardReader' do |bleMF1CardReader|
  bleMF1CardReader.source_files = 'XTModuleBLEMF1Card/BLEMF1CardReader/*'
  bleMF1CardReader.dependency 'XTModuleBLEMF1Card/Models'
  bleMF1CardReader.dependency 'XTModuleBLEMF1Card/3FSDK'
  end

  # s.resource_bundles = {
  #   'XTModuleBLEMF1Card' => ['XTModuleBLEMF1Card/Assets/*.png']
  # }

  # b = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
  s.dependency 'XTComponentUtils'
end
