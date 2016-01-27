Pod::Spec.new do |s|
  s.name = 'anim'
  s.version = '0.0.7'
  s.license = { :type => "MIT", :file => "LICENSE" }
  s.summary = 'Swift animations with more easing options.'
  s.homepage = 'https://github.com/onurersel/anim'
  s.authors = { 'Onur Ersel' => 'onurersel@gmail.com' }
  s.source = { :git => 'https://github.com/onurersel/anim.git', :tag => s.version }

  s.ios.deployment_target = '8.0'
  s.tvos.deployment_target = '9.0'

  s.source_files = 'anim/anim.swift'

  s.requires_arc = true
end