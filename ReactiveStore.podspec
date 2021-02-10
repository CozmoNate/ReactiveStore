Pod::Spec.new do |s|
  s.name             = 'ReactiveStore'
  s.version          = '3.0.0'
  s.summary          = 'Simple reactive store implementation for state management written in Swift.'
  s.homepage         = 'https://github.com/kzlekk/ReactiveStore'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Natan Zalkin' => 'natan.zalkin@me.com' }
  s.source           = { :git => 'https://kzlekk@github.com/kzlekk/ReactiveStore.git', :tag => "#{s.version}" }
  s.module_name      = 'ReactiveStore'
  s.swift_version    = '5.1'

  s.ios.deployment_target = '12.0'
  s.osx.deployment_target = '10.14'
  s.watchos.deployment_target = '5.0'
  s.tvos.deployment_target = '12.0'

  s.subspec 'Core' do |cs|
    cs.source_files = 'ActionDispatcher/*.swift'
  end

  s.subspec 'Observing' do |cs|
    cs.dependency 'ReactiveStore/Core'
    cs.source_files = 'ReactiveStore/*.swift'
  end

  s.default_subspec = 'Core'

end
