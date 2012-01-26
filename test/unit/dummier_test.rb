require 'test_helper'

class DummierTest < MiniTest::Should::TestCase

  def setup
    @root = File.expand_path("../../../", __FILE__)
  end
  
  should "include executable" do
    assert File.executable?(File.join(@root, "bin/dummier"))
  end
  
  should "have classes defined" do
    assert defined?(Dummier)
    assert defined?(Dummier::AppGenerator)
  end
  
end
