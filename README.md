Dummier
=======

A smart gem with a dumb name; Dummier is a rails generator for automating the creation of rails testing applications. 

Dummier was inspired by [José Valim](https://github.com/josevalim)'s [enginex](https://github.com/josevalim/enginex) which creates a standard gem structure for you. Enginex creates a `test/dummy` app for you, but what if we want to re-create it? Or leave it out of git?

The idea behind Dummier is that we don't check `test/dummy` into git, but rather generate it on the fly for the gems we're developing. It just seems [DRY](http://en.wikipedia.org/wiki/Don't_repeat_yourself)'er that way.

Dummier is simple; just run the binary from your gem's root directory and it will generate a stripped-down & gem-dev-ready rails app in `test/dummy`. While it's doing it's thing, Dummer triggers a few hooks along the way for easy customization.

To catch the hooks, just create appropriately named files in `test/dummy_hooks` inside your gem. See **Hooks** below for more info.


Installation
------------

To install from RubyGems:

    gem install dummier

To install with bundler:

    gem 'dummier', '>= 0.2.2'

To package for development in your gemspec:
    
    s.add_development_dependency('dummier', '>= 0.2.2')
    
    
Usage
-----

After you've installed Dummier, just `cd` into the gem your developing and run the binary:

    dummier
    
If you're in a gem that uses bundler, you may have to run the binary with `bundle exec`: 

    bundle exec dummier
    

Hooks
-----
    
Dummier calls the following hooks along the way:

    before_delete
    before_app_generator
    after_app_generator
    before_migrate
    after_migrate
    
    
Place appropriately named files ) in `test/dummy_hooks` and dummier will find and execute them automatically! 

You can use [Rails::Generators::Actions](http://api.rubyonrails.org/classes/Rails/Generators/Actions.html) as well as [Thor::Actions](http://textmate.rubyforge.org/thor/Thor/Actions.html) in your hooks. Also, since hooks are just `eval`'d into the [Dummer::AppGenerator](http://rubydoc.info/gems/dummier/0.2.2/Dummier/AppGenerator), you have access to all of [those methods](http://rubydoc.info/gems/dummier/0.2.2/Dummier/AppGenerator) as well. 
    
    
### Simple Example

Here's a `before_migrate.rb` hook that will install [Spree Commerce](https://github.com/spree/spree) by running some rake commands before migrating the `test/dummy` database.

    # test/dummy_hooks/before_migrate.rb
    say_status "installing", "spree_core, spree_auth and spree_sample"
    rake "spree_core:install spree_auth:install spree_sample:install"
    
    
### More Complex Example

Here's an example taken from [has_magick_title](https://github.com/citrus/has_magick_title):

    # test/dummy_hooks/after_app_generator.rb
    run "rails g scaffold post title:string"
    
    gsub_file "app/models/post.rb", "end", %(
      has_magick_title
      
    end)
    
    gsub_file "config/routes.rb", "resources :posts", %(
      resources :posts
      root :to => "posts#index")
    
    gsub_file "app/views/posts/show.html.erb", "<%= @post.title %>", %(
      <%= magick_title_for @post %>)


Testing
-------

To get setup for testing, clone this repo, bundle up and run rake.

    git clone git://github.com/citrus/dummier.git
    cd dummier
    bundle install
    rake


Enjoy!


Change Log
----------


**0.2.2 - 2011/8/31**

* added to travis-ci.org
* fixed ruby 1.8.7, rbx and ree compatibility


**0.2.1 - 2011/8/31**

* merged GH#1 - Thanks @holdensmagicalunicorn
* revised readme


**0.2.0 - 2011/6/18**

* moved the dummy_hooks to your test folder rather than in lib. makes more sense that way.


**0.1.1 - 2011/6/1**

* added your gem's `test/dummy_hooks/templates` folder into the generator's `source_paths`


**0.1.0 - 2011/5/20**

* removed spork and wrote a basic hook test
* improved documentation


**0.1.0.rc1 - 2011/5/11**

* added spork and some tests


**2011/5/10**

* it exists!


Contributors
------------

- Spencer Steffen ([@citrus](https://github.com/citrus))
- [@holdensmagicalunicorn](https://github.com/holdensmagicalunicorn)


License
-------

Copyright (c) 2011 Spencer Steffen and Citrus, released under the New BSD License All rights reserved.
