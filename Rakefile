require "rake/testtask"
Rake::TestTask.new do |t|
  t.libs << "test"
  t.pattern = "test/{classes,utils}/*_spec.rb"
  t.verbose = true
end

task default: [:test]
