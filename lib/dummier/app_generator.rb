require "fileutils"
require "rails/generators"
require "rails/generators/rails/app/app_generator"

# Much of this generator came from enginex by José Valim
# https://github.com/josevalim/enginex/blob/master/lib/enginex.rb

module Dummier
  
  class AppGenerator < Rails::Generators::Base
    
    source_root File.expand_path('../../templates', __FILE__)
    
    # Default generator options
    def defaults
      { :verbose => false }
    end
    
    def initialize(root, options={})
      @behavior = :invoke
      @root_path = File.expand_path(root)
      @destination_stack = []
      @options = defaults.merge(options)
      self.source_paths << File.join(root_path, "test", "dummy_hooks", "templates")      
      self.destination_root = File.join(test_path, name)
      raise "Invalid directory!" unless File.directory?(@root_path)
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
    
    # Loads a hook file and evalutes its contents. 
    # rescues any exceptions and logs their message.
    # Store hooks in gem_root/test/dummy_hooks
    def fire_hook(hook_name)
      begin
        file = File.join(root_path, "test/dummy_hooks/#{hook_name}.rb")
        say_status "hook", hook_name, File.exists?(file) ? :cyan : :red
        eval File.read(file) if File.exists?(file)
      rescue Exception => e
        say_status "failed", "#{hook_name} raised an exception", :red
        say e.message.strip + "\n", :red
      end
    end
    
    # Runs the generator
    def run!
      fire_hook :before_delete
      remove_existing_dummy
      fire_hook :before_app_generator
      run_base_generator
      fire_hook :after_app_generator
      inside destination_path do
        remove_unnecessary_files
        replace_boot_templates
        add_cucumber_support if has_features?
        fire_hook :before_migrate
        run_migration
        fire_hook :after_migrate
      end
    end
    
    private
      
      # Removes existing test app 
      def remove_existing_dummy
        FileUtils.rm_r(destination_path) if File.directory?(destination_path)
      end
      
      # Runs the base app generator
      def run_base_generator
        Rails::Generators::AppGenerator.start([destination_path])
      end
      
      # Removes unnecessary files from test/dummy
      def remove_unnecessary_files
        files = %w(public/index.html public/images/rails.png Gemfile README doc test vendor)
        files.each do |file|
          say_status "delete", file
          FileUtils.rm_r(file) if File.exists?(file)
        end
      end

      # Replaces application.rb and boot.rb with dummier's templates      
      def replace_boot_templates
        template "rails/application.rb", "config/application.rb", :force => true
        template "rails/boot.rb",        "config/boot.rb",        :force => true       
      end
      
      # Add cucumber config to database.yml
      def add_cucumber_support   
        unless File.read(File.join(destination_path, "config/database.yml")) =~ /cucumber/
          gsub_file   "config/database.yml", "test:", "test: &test"
          append_file "config/database.yml" do
%(
cucumber:
  <<: *test
)         
          end
        end
        env = "config/environments/cucumber.rb"
        unless File.exists?(File.join(destination_path, env))
          FileUtils.cp(File.join(destination_path, "config/environments/test.rb"), env)
        end
      end
      
      # Runs db:migrate on the test database
      def run_migration
        rake("db:migrate", :env => "test")
      end
      
      # Checks for ./features within the gem's root path
      def has_features?
        File.directory?(File.join(root_path, "features"))  
      end
    
  end
end