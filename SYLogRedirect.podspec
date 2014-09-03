Pod::Spec.new do |s|
  s.name     = 'SYLogRedirect'
  s.version  = '1.0'
  s.license  = 'Custom'
  s.summary  = 'Log redirect tool'
  s.homepage = 'https://github.com/dvkch/SYLogRedirect'
  s.author   = { 'Stan Chevallier' => 'contact@stanislaschevallier.fr' }
  s.source   = { :git => 'https://github.com/dvkch/SYLogRedirect.git' }
  s.source_files = 'SYLogRedirect.{h,m}'
  s.requires_arc = true

  s.xcconfig = { 'CLANG_MODULES_AUTOLINK' => 'YES' }
  s.ios.deployment_target = '5.0'
end
