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

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
