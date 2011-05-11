require_relative '../test_helper'

class DummierTest < Test::Unit::TestCase

  def setup
    @root  = File.expand_path("../../../", __FILE__)
    @dummy = File.join(@root, "test/dummy")
  end
  
  def read_file(file)
    File.read(File.join(@dummy, file))
  end

  should "have classes defined" do
    assert defined?(Dummier)
    assert defined?(Dummier::AppGenerator)
  end

  should "create test/dummy" do
    
    # remove existing dummy
    FileUtils.rm_r(@dummy) if File.exists?(@dummy)
    assert !File.exists?(@dummy)
        
    # run generator
    Dummier::AppGenerator.new(@root).run!

    # make sure the dummy is created
    assert File.exists?(@dummy)
    
    # make sure things that should get deleted do
    files = %w(public/index.html public/images/rails.png Gemfile README doc test vendor)
    files.each do |file|
      assert !File.exists?(file)
    end
    
    # make sure application template is applied
    rb = read_file('config/application.rb')
    [ "require File.expand_path('../boot', __FILE__)", /require "dummier"/, /module Dummy/ ].each do |regex|
      assert_match regex, rb
    end
    
    # make sure boot template is applied
    rb = read_file('config/boot.rb')
    [ "gemfile = File.expand_path('../../../../Gemfile', __FILE__)", "ENV['BUNDLE_GEMFILE'] = gemfile", "$:.unshift File.expand_path('../../../../lib', __FILE__)" ].each do |regex|
      assert_match regex, rb
    end    
    
  end

  context "with some hooks" do
    # todo
  end

end