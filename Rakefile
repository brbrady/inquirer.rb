require "rake/testtask"
Rake::TestTask.new do |t|
  t.libs << "test"
  t.pattern = "test/{classes,utils}/*_spec.rb"
  t.verbose = false
  t.warning = false
end

task default: [:test]
