desc "preps the testing environment"
task :build_dummy do
  require 'dummier'
  dir = `pwd`.strip
  puts dir.inspect
  Dummier::AppGenerator.new(dir).run!
end