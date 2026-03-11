lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
#require 'sandbox_mruby_process/version.rb'

Gem::Specification.new do |s|
  s.name = 'sandbox_mruby_process'
  #s.version =  SandboxMrubyProcess::VERSION
  s.version =  "0.0.1"
  s.author = "Weston Ganger"
  s.email = 'weston@westonganger.com'
  s.homepage = 'https://github.com/westonganger/sandbox_mruby_process'

  s.summary = "Sandbox MRuby Process"
  s.description = s.summary
  s.license = 'MIT'

  s.files = Dir.glob("{lib/**/*}") + ["LICENSE", "README.md", "Rakefile", "CHANGELOG.md"]
  s.require_path = 'lib'

  s.add_dependency "rake-compiler"

  s.add_development_dependency 'rake'
end
