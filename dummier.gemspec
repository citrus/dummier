# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "dummier/version"

Gem::Specification.new do |s|

  s.name        = "dummier"
  s.version     = Dummier::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Spencer Steffen"]
  s.email       = ["spencer@citrusme.com"]
  s.homepage    = "https://github.com/citrus/dummier"
  s.summary     = %q{Dummier generates a minimal rails testing application.}
  s.description = %q{Dummier is a rails generator for automating the creation of rails testing applications.}

  s.rubyforge_project = "dummier"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency('rails', '>= 3')

  s.add_development_dependency('minitest',        '>= 2')
  s.add_development_dependency('minitest_should', '~> 0.3')
  s.add_development_dependency('sqlite3',         '~> 1.3')

end
