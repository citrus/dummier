require 'bundler/setup'
Bundler.require(:default, :test)
require 'minitest/autorun'
require 'minitest/should'
require 'fileutils'

require 'support/test_case'
require 'support/hook_test_helper'
