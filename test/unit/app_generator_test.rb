require 'test_helper'

class AppGeneratorTest < MiniTest::Should::TestCase

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
        capture(:stdout) { @generator.run! }
      end

      should "create test/dummy and apply proper templates" do
        # should create test/dummy
        assert File.exists?(@dummy), "test/dummy should exist at #{@dummy}"

        # should remove unnecessary files
        files = %w(public/index.html public/images/rails.png Gemfile README doc test vendor)
        files.each do |file|
          assert !File.exists?(file), "#{file} should have been deleted"
        end

        # should apply application template
        rb = read_file('config/application.rb')
        [ "require File.expand_path('../boot', __FILE__)", /require "dummy_gem"/, /module Dummy/ ].each do |regex|
          assert_match regex, rb, "config/application should have had #{rb.inspect} applied."
        end

        # should apply the boot template
        rb = read_file('config/boot.rb')
        [ "gemfile = File.expand_path('../../../../Gemfile', __FILE__)", "ENV['BUNDLE_GEMFILE'] = gemfile", "$:.unshift File.expand_path('../../../../lib', __FILE__)" ].each do |regex|
          assert_match regex, rb, "config/boot.rb should have had #{rb.inspect} applied."
        end

        # should fire hooks in proper order
        assert_equal [ :before_delete, :before_app_generator, :after_app_generator, :before_migrate, :after_migrate ], HookTestHelper.hooks
      end

    end

    context "with cucumber features, when run" do

      setup do
        @features = File.join(@root, "features")
        FileUtils.mkdir(@features)
        capture(:stdout) { @generator.run! }
      end

      teardown do
        FileUtils.rm_r(@features) if File.directory?(@features)
      end

      should "apply cucumber support" do
        # should write database config
        yml = read_file('config/database.yml')
        [ "test: &test", "cucumber:", "  <<: *test" ].each do |regex|
          assert_match regex, yml, "config/database.yml should have had #{yml.inspect} applied"
        end

        # should apply cucumber environment
        env = "config/environments/cucumber.rb"
        assert File.exists?(File.join(@dummy, env)), "#{env.inspect} should have been created"
      end

    end

  end

  context "A doomed to fail app generator" do

    setup do
      # create a failed destiny
      @hooks = File.join(@root, "test/dummy_hooks")
      @tmp   = File.join(@root, "test/tmp_dummy_hooks")
      @err   = File.join(@root, "test/erroneous_dummy_hooks")
      FileUtils.mv @hooks, @tmp
      FileUtils.mv @err, @hooks
      @generator = Dummier::AppGenerator.new(@root)
    end

    teardown do
      # revert to sanity
      FileUtils.mv @hooks, @err
      FileUtils.mv @tmp, @hooks
    end

    should "error and exit if a hook throws an exception" do
      # ensure exception is raised
      assert_raises Dummier::HookException do
        capture(:stdout) { @generator.run! }
      end
      # ensure the generator didn't make it any farther
      assert HookTestHelper.hooks.empty?
    end

  end

end
