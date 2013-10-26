Pod::Spec.new do |s|
  s.name     = 'UnQueLight'
  s.version  = '0.0.1'
  s.author   =  { 'Alexey Aleshkov' => 'djmadcat@gmail.com' }
  s.license  = { :type => 'BSD', :file => 'LICENSE' }
  s.homepage = 'https://github.com/djmadcat/UnQueLight'
  s.summary  = 'An Objective-C wrapper around UnQLite'
  s.description = 'Project is in alpha development stage. Please do not use in production.'

  s.requires_arc = true

  s.source_files = 'UnQueLight/*.{h,m}'

  s.ios.deployment_target = '5.0'
  s.osx.deployment_target = '10.7'

  s.prefix_header_contents = <<-EOS
#define UNQLITE_ENABLE_THREADS 1
EOS
end
