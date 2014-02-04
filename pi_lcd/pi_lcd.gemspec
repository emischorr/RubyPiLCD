# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pi_lcd/version'

Gem::Specification.new do |spec|
  spec.name          = "pi_lcd"
  spec.version       = PiLcd::VERSION
  spec.authors       = ["Enrico Mischorr"]
  spec.email         = ["enrico@mischorr.de"]
  spec.description   = %q{Control a HD44780-compatible LCD on the Raspberry PI}
  spec.summary       = %q{Control a HD44780-compatible LCD on the Raspberry PI}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_runtime_dependency "pi_piper"
end
