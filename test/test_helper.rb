require 'fileutils'
require 'spork'

Spork.prefork do

  require 'bundler/setup'
  Bundler.require(:default, :test)
  require 'shoulda'
  
end

Spork.each_run do

  #Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
    
end
