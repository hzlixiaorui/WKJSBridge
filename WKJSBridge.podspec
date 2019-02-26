Pod::Spec.new do |s|
  s.name = 'WKJSBridge'
  s.version = '0.0.1'
  s.license = 'MIT'
  s.summary = 'A type-safe JSBridge for WKWebView with pure Swift.'
  s.homepage = 'https://github.com/NSLogMeng/WKJSBridge'
  s.authors = { 'Meng' => 'meng94233@gmail.com' }
  s.source = { :git => 'https://github.com/NSLogMeng/WKJSBridge.git', :tag => "#{s.version}" }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'

  s.source_files = 'Sources/**/*.swift'
  s.resources = 'Resources/*.js'

  s.swift_version = '4.2'
end
