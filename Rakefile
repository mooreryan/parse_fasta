require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rake/extensiontask"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

Rake::ExtensionTask.new do |ext|
  ext.name    = "parse_fasta"
  ext.ext_dir = "ext/parse_fasta"
  ext.lib_dir = "lib/parse_fasta"
end

Rake::Task[:spec].prerequisites << :compile
