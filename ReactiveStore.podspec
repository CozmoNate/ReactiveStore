Pod::Spec.new do |s|
  s.name             = 'ReactiveStore'
  s.version          = '1.0.0'
  s.summary          = 'Simple reactive store implementation for state management written in Swift.'
  s.homepage         = 'https://github.com/kzlekk/ReactiveStore'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Natan Zalkin' => 'natan.zalkin@me.com' }
  s.source           = { :git => 'https://kzlekk@github.com/kzlekk/ReactiveStore.git', :tag => "#{s.version}" }
  s.module_name      = 'ReactiveStore'
  s.swift_version    = '5.0'

  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = '10.12'
  s.watchos.deployment_target = '3.0'
  s.tvos.deployment_target = '10.0'

  s.source_files = 'ReactiveStore/*.swift'

end
