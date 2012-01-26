require 'bundler/setup'
Bundler.require(:default, :test)
require 'minitest/autorun'
require 'minitest/should'
require 'fileutils'
require File.expand_path('../support/hook_test_helper', __FILE__)
