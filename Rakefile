# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "status_enumerator"
  gem.homepage = "http://github.com/Ktouth/status_enumerator"
  gem.license = "MIT"
  gem.summary = %Q{This class provides an enumeration function to have the object which I added tree information to in an argument}
  gem.description = <<-ENDE
This class provides an enumeration function to have the object which I added tree information to in an argument.
The instance receives an enumerable object and provides #each and #each_method. The #each method calls a block in an argument in own. The #each_method method calls the method of an object appointed own in an argument.
I have the information of the object equal to the ancestors in own and front and back and hierarchy structure, and a block and the argument handed to a method maintain the state flag in the enumeration again.
It is necessary to appoint the information about the descendant in the hierarchy structure in a block - a method explicitly. When the #into method receives an enumerable object, and a block is not exhibited, a block - a method is used recursively.
This class provides a function to enumerate it, but it is not the object which it can enumerate.
ENDE
  gem.email = "ktouth@k-brand.gr.jp"
  gem.authors = ["Keiichiro Nishi"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :default => :spec

require 'rdoc/task'
RDoc::Task.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "status_enumerator #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.options = ["--charset", "utf-8", "--line-numbers"]
end
