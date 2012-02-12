require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rake/packagetask'
require 'rubygems/package_task'
require 'rdoc/task'
require 'rake/contrib/sshpublisher'
require 'spec/rake/spectask'
require 'fileutils'
include FileUtils

$LOAD_PATH.unshift "lib"
require "echonest"


task :default => [:spec]
task :package => [:clean]

Spec::Rake::SpecTask.new do |t|
  t.spec_opts = ['--options', "spec/spec.opts"]
  t.spec_files = FileList['spec/*_spec.rb']
  t.rcov = true
end

spec = eval(File.read("bassnode-ruby-echonest.gemspec"))
Gem::PackageTask.new(spec) do |p|
  p.need_tar = true
  p.gem_spec = spec
end


desc "Show information about the gem"
task :debug_gem do
  puts spec.to_ruby
end

