require "rake/testtask"

task :default => :test

Rake::TestTask.new {|t| t.test_files = ['test/test.rb']}

task :clean do
  sh "rm -rf *.gem doc pkg coverage `find . -name '*.rbc'`"
end

task :gem do
  sh "gem build fatalistic.gemspec"
end