Pod::Spec.new do |spec|
  spec.name         = 'JoRefresh'
  spec.summary      = 'A iOS UI components.'
  spec.version      = '0.1.5'
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.authors      = { 'django' => 'djangolei@gmail.com' }
  spec.homepage     = 'https://github.com/djangolee/JoRefresh'
  spec.source       = { :git => 'https://github.com/djangolee/JoRefresh.git', :tag => spec.version.to_s }
  spec.requires_arc = true
  spec.ios.deployment_target = '8.0'
  spec.source_files = 'Source/**/*.{swift}'
  spec.swift_version = '4.2'

end
