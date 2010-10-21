require 'rubygems'
require 'rake'
require 'rake/rdoctask'
require 'rspec/core/rake_task'


desc 'Default: run unit tests.'
task :default => :test

desc 'Generate documentation for the collection_filters plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'CollectionFilters'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "collection_filters"
    gem.summary = %Q{TODO: one-line summary of your gem}
    gem.description = %Q{TODO: longer description of your gem}
    gem.email = "anthony@namelessnotion.com"
    gem.homepage = "http://github.com/namelessnotion/collection_filters"
    gem.authors = ["anthony"]
    gem.add_development_dependency "rspec", ">= 1.2.9"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end


desc 'Test the Collection Filters plugin.'
RSpec::Core::RakeTask.new('spec') do |t|
  t.pattern = FileList['spec/**/*_spec.rb']
end