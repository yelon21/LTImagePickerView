#
# Be sure to run `pod lib lint LTImagePickerView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LTImagePickerView'
  s.version          = '0.1.0'
  s.summary          = 'A short description of LTImagePickerView.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/yelon21/LTImagePickerView'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '254956982@qq.com' => 'yelon21' }
  s.source           = { :git => 'https://github.com/yelon21/LTImagePickerView.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/yelon21'

  s.ios.deployment_target = '7.0'

  s.source_files = 'LTImagePickerView/Classes/**/*'
s.resource     = 'LTImagePickerView/Assets/*.{xib,png}'

  # s.resource_bundles = {
  #   'LTImagePickerView' => ['LTImagePickerView/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
