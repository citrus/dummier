require "fileutils"
require "rails/generators"
require "rails/generators/rails/app/app_generator"

# Much of this generator came from enginex by José Valim
# https://github.com/josevalim/enginex/blob/master/lib/enginex.rb

module Dummier
  
  class AppGenerator < Rails::Generators::Base
    
    source_root File.expand_path('../../templates', __FILE__)
    
    def defaults
      { :verbose => false }
    end
    
    def initialize(root, options={})
      @behavior = :invoke
      @root_path = File.expand_path(root)
      @destination_stack = []
      @options = defaults.merge(options)
      self.destination_root = File.join(test_path, name)
      raise "Invalid directory!" unless Dir.exists?(@root_path)
    end
    
    # The name of the rails application
    def name
      "dummy"
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
    
    # loads a hook file and evalutes its contents. 
    # rescues any exceptions and logs their message.
    # store hooks in your_extension/lib/dummy_hooks
    def fire_hook(hook_name)
      begin
        file = File.join(root_path, "lib/dummy_hooks/#{hook_name}.rb")
        say_status "hook", hook_name, File.exists?(file) ? :cyan : :red
        if File.exists?(file)
          rb = File.read(file) 
          eval(rb)    
        end
      rescue Exception => e
        say_status "failed", "#{hook_name} raised an exception", :red
        say e.message.strip + "\n", :red
      end        
    end
    
    
    
    # Runs the generator
    def run!
      
      fire_hook :before_delete
      
      # remove existing test app 
      FileUtils.rm_r(destination_path) if File.directory?(destination_path)

      fire_hook :before_app_generator
        
      # run the base app generator
      Rails::Generators::AppGenerator.start([destination_path])
      
      fire_hook :after_app_generator
      
      inside destination_path do
                
        # remove unnecessary files    
        files = %w(public/index.html public/images/rails.png Gemfile README doc test vendor)
        files.each do |file|
          say_status "delete", file
          FileUtils.rm_r(file) if File.exists?(file)
        end

        # replace crucial templates
        template "rails/application.rb", "config/application.rb", :force => true
        template "rails/boot.rb",        "config/boot.rb",        :force => true
                
        # add cucumber to database.yml
        cukes = Dir.exists?(File.join(root_path, "features"))
        if cukes
          append_file "config/database.yml" do
%(
cucumber:
  <<: *test
)
          end
        end
        
        fire_hook :before_migrate
                
        rake("db:migrate", :env => "test")
        
        fire_hook :after_migrate
        
      end  
      
    end
  end
end