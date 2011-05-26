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
  gem.name = "deployflow"
  gem.homepage = "http://github.com/nmeans/deployflow"
  gem.license = "MIT"
  gem.summary = %Q{Quiet multistage versioning/deployment strategy using git-flow and capistrano-multistage}
  gem.description = %Q{Quiet multistage versioning/deployment strategy using git-flow and capistrano-multistage}
  gem.email = "nick@activeprospect.com"
  gem.authors = ["Nickolas Means"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new
