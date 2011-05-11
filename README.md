Dummier
=======

**Under construction**

A smart gem with a dumb name; Dummier is a rails generator for automating the creation of rails testing applications. These applications usually live in test/dummy, and we see them alot.

It's just not cool having so many empty, un-loved rails apps hiding away in the /test directory of all these fun gems. Let's give them some more attention by using dummier to make it exciting to generate these apps!

Once dummier is ready for action, you'll cd into your existing gem and run `bundle exec dummier`.

You can create custom hooks that fire along the way by placing the appropriately named files in `your_gem/lib/dummy_hooks/hook_name.rb`.

That's all for now.


Installation
------------

Don't do that quite yet.


Testing
-------

To get setup for testing, clone this repo, bundle up and run rake.

    git clone git://github.com/citrus/dummier.git
    cd dummier
    bundle install
    rake

Or do this if you want to spork:

    git clone git://github.com/citrus/dummier.git
    cd dummier
    bundle install
    bundle exec spork
    
    # in another window
    cd back/to/dummier
    testdrb test/**/*_test.rb

Enjoy!



To Do
-----

* testing..
* get migrate task to work


Change Log
----------

**2011/5/11**

* added spork and some tests

**2011/5/10**

* it exists!


License
-------

Copyright (c) 2011 Spencer Steffen and Citrus, released under the New BSD License All rights reserved.