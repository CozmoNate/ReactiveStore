Pod::Spec.new do |s|
  s.name             = 'ReactiveStore'
  s.version          = '4.0.0'
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

  s.subspec 'Dispatcher' do |cs|
    cs.source_files = 'Dispatcher/*.swift'
  end

  s.subspec 'ReactiveObject' do |cs|
    cs.dependency 'ReactiveStore/Dispatcher'
    cs.source_files = 'ReactiveObject/*.swift'
  end

  s.default_subspec = 'Dispatcher'

end
