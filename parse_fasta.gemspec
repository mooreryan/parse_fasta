# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "parse_fasta/version"

Gem::Specification.new do |spec|
  spec.name        = "parse_fasta"
  spec.version     = ParseFasta::VERSION
  spec.authors     = ["Ryan Moore"]
  spec.email       = ["moorer@udel.edu"]
  spec.summary     = %q{Easy-peasy parsing of fasta & fastq files!}
  spec.description = <<-EOF
Provides nice, programmatic access to fasta and fastq files, as well as providing Sequence and Quality helper classes. No need for BioRuby ;)
  EOF
  spec.homepage = "https://github.com/mooreryan/parse_fasta"
  spec.license  = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) {|f| File.basename(f)}
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.1"

  spec.add_development_dependency "bundler", "~> 1.16", ">= 1.16.1"
  spec.add_development_dependency "rake", "~> 12.3", ">= 12.3.1"
  spec.add_development_dependency "rspec", "~> 3.7"
  spec.add_development_dependency "bio", "~> 1.4"
  spec.add_development_dependency "yard", "~> 0.9.12"
  spec.add_development_dependency "coveralls", "~> 0.8.21"
  spec.add_development_dependency "benchmark-ips", "~> 2.7", ">= 2.7.2"
end
