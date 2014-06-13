# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'parse_fasta/version'

Gem::Specification.new do |spec|
  spec.name          = "parse_fasta"
  spec.version       = ParseFasta::VERSION
  spec.authors       = ["Ryan Moore"]
  spec.email         = ["moorer@udel.edu"]
  spec.summary       = %q{Easy-peasy parsing of fasta files}
  spec.description   = %q{So you want to parse a fasta file...}
  spec.homepage      = "https://github.com/mooreryan/parse_fasta"
  spec.license       = "GPLv3: http://www.gnu.org/licenses/gpl.txt"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.0"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.3"
  spec.add_development_dependency "rspec", "~> 2.14"
  spec.add_development_dependency "bio", "~> 1.4"
  spec.add_development_dependency "yard", "~> 0.8"
end
