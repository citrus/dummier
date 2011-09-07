require 'test_helper'

class AppGeneratorTest < Test::Unit::TestCase

  def setup
    @root  = File.expand_path("../../dummy_gem", __FILE__)
    @dummy = File.join(@root, "test/dummy")
    Dir.chdir(@root)
    HookTestHelper.reset!
    # remove existing dummy
    FileUtils.rm_r(@dummy) if File.directory?(@dummy)
    assert !File.directory?(@dummy)
  end
  
  def read_file(file)
    File.read(File.join(@dummy, file))
  end

  should "have classes defined" do
    assert defined?(Dummier)
    assert defined?(Dummier::AppGenerator)
  end
      
  context "A new app generator" do
    
    setup do
      @generator = Dummier::AppGenerator.new(@root)  
    end
     
    should "include test/dummy_hooks/templates in the generators source paths" do      
      assert @generator.source_paths.include?(File.join(@root, "test/dummy_hooks/templates"))
    end
    
    context "when run" do
      
      setup do
        @generator.run!    
      end
      
      should "create test/dummy" do
        assert File.exists?(@dummy)
      end
    
      should "remove unnecessary files" do        
        files = %w(public/index.html public/images/rails.png Gemfile README doc test vendor)
        files.each do |file|
          assert !File.exists?(file)
        end   
      end
            
      should "apply application template" do
        rb = read_file('config/application.rb')
        [ "require File.expand_path('../boot', __FILE__)", /require "dummy_gem"/, /module Dummy/ ].each do |regex|
          assert_match regex, rb
        end
      end
        
      should "apply the boot template" do
        rb = read_file('config/boot.rb')
        [ "gemfile = File.expand_path('../../../../Gemfile', __FILE__)", "ENV['BUNDLE_GEMFILE'] = gemfile", "$:.unshift File.expand_path('../../../../lib', __FILE__)" ].each do |regex|
          assert_match regex, rb
        end
      end
        
      should "fire hooks in proper order" do
        assert_equal [ :before_delete, :before_app_generator, :after_app_generator, :before_migrate, :after_migrate ], HookTestHelper.hooks
      end
        
    end
    
    context "with cucumber features, when run" do
      
      setup do
        @features = File.join(@root, "features")
        FileUtils.mkdir(@features)
        @generator.run!
      end
      
      teardown do
        FileUtils.rm_r(@features) if File.directory?(@features)
      end
      
      should "apply cucumber database config" do
        yml = read_file('config/database.yml')
        [ "test: &test", "cucumber:", "  <<: *test" ].each do |regex|
          assert_match regex, yml
        end
      end
      
      should "apply cucumber environment" do
        assert File.exists?(File.join(@dummy, "config/environments/cucumber.rb"))
      end
      
    end

  end
  
end