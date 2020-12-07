Pod::Spec.new do |s|
  s.name             = 'DAAttributedLabel'
  s.version          = '0.2.5'
  s.summary          = 'A custom AttributedLabel using TextKit to replace UILabel.'
  s.description      = <<-DESC
  A custom AttributedLabel using TextKit to replace UILabel.
  You can customization truncationToken, lineSpacing and backgroundColor, and also you can add custom view attachments.
                       DESC

  s.homepage         = 'https://github.com/darkangel7/DAAttributedLabel'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'darkangel7' => '535596858@qq.com' }
  s.source           = { :git => 'https://github.com/darkangel7/DAAttributedLabel.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.source_files = 'DAAttributedLabel/Classes/**/*'
  s.public_header_files = 'DAAttributedLabel/Classes/**/*.h'
  s.frameworks = 'UIKit', 'Foundation'
end
