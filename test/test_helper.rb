require 'bundler/setup'
Bundler.require(:default, :test)
require 'shoulda'
require 'fileutils'
require File.expand_path('../support/hook_test_helper', __FILE__)
