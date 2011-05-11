require "fileutils"
require "thor/shell" 
require "rails/generators"
require "rails/generators/rails/app/app_generator"


# Much of this generator came from enginex by José Valim
# https://github.com/josevalim/enginex/blob/master/lib/enginex.rb

module Dummier
  
  class AppGenerator < Rails::Generators::Base
    
    include Thor::Shell
    
    source_root File.expand_path('../../templates', __FILE__)
    
    def initialize(root)
      @root_path = File.expand_path(root)
      @destination_stack = []
      self.destination_root = File.join(test_path, name)
      raise "Invalid directory!" unless Dir.exists?(@root_path)
    end
    
    # The name of the rails application
    def name
      "dummy"
    end
    
    def options
      @options ||= {}
    end
    
    # The name of the extension to be tested
    def extension
      File.basename(root_path)
    end
    
    # The name, camelized
    def camelized
      @camelized ||= name.camelize
    end
  
    # The name, underscored
    def underscored
      @underscored ||= name.underscore
    end
    
    # Path the the extension's root folder
    def root_path 
      @root_path
    end    
    
    # Path to the extension's test folder
    def test_path
      File.join(root_path, "test")
    end
    
    # Path to the testing application
    def destination_path
      File.join(test_path, name)
    end
    
    # gets the current application.rb contents
    def application_definition
      @application_definition ||= begin
        contents = File.read("#{destination_root}/config/application.rb")
        contents[(contents.index("module Dummy"))..-1]
      end
    end
    alias :store_application_definition! :application_definition
  
    
    
    # Runs the generator
    def run!
    
      # remove existing test app 
      FileUtils.rm_r(destination_path) if File.directory?(destination_path)

      # run the base app generator
      Rails::Generators::AppGenerator.start([destination_path])
      
      
      rake("db:migrate", :env => "test")
      
      #   
      #
        
      #end
        
      # remove unnecessary files    
      #
        
        #puts "SOURC:"
        #puts source_paths
        #
        #puts "DEST:"
        #puts destination_root.class
        #puts destination_root
        #      
        
        # replace crucial templates
        #template "rails/boot.rb",        "#{destination_root}/config/boot.rb",        :force => true
        #template "rails/application.rb", "#{destination_root}/config/application.rb", :force => true    
        #
        ## install spree and migrate db
        #run "rake spree_core:install spree_auth:install spree_sample:install"
        #run "rails g #{extension}:install"
        #run "rake db:migrate RAILS_ENV=test"
        #
        ## add cucumber to database.yml
        #append_file "#{destination_root}/config/database.yml" do
        #  %(cucumber:
        #    <<: *test)
        #end
        
      #end  
      
    end
  end
end