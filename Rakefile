require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList["test/**/*_spec.rb"]
  t.verbose = true
  t.warning = true
end

task :default => :test