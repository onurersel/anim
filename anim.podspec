Pod::Spec.new do |s|
  s.name = 'anim'
  s.version = '1.1.5'
  s.license = { :type => "MIT", :file => "LICENSE" }
  s.summary = 'Swift animation library for iOS and macOS'
  s.homepage = 'https://github.com/onurersel/anim'
  s.authors = { 'Onur Ersel' => 'onurersel@gmail.com' }
  s.social_media_url = 'https://twitter.com/ethestel'
  s.source = { :git => 'https://github.com/onurersel/anim.git', :tag => s.version }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'

  s.source_files = 'src/*.swift'
  s.requires_arc = true
end
