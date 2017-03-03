Pod::Spec.new do |s|
  s.name             = 'XMImagePicker'
  s.version          = '0.1.0'
  s.summary          = 'image picker'
  s.homepage         = 'https://github.com/hucool/XMImagePicker'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'tiger' => 'tiger@socool@gmail.com' }
  s.source           = { :git => 'https://github.com/hucool/XMImagePicker.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.source_files = 'Pod/Classes/**/*'

  s.resources = 'Pod/image.bundle'
  s.frameworks = 'UIKit', 'Foundation', 'Photos'
  s.dependency 'WXImageCompress', '~> 0.1.1'
end
