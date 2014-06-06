module Oppsie
	module Generators
		class InstallGenerator < Rails::Generators::Base
		  source_root File.expand_path("../templates", __FILE__)

		  def initialize(runtime_args, runtime_options = {}, wat)
		    @stack_id = runtime_args[0]
		    @app_id = runtime_args[1]
		    super
		  end

		  def install
		  	create_settings_config
		  	copy_rake_file
		  end

 		  def help
		  	puts " use 'rails g oppsie:install {stack_id} {app_id}' to generate the needed yml file and rake tasks"
		  end
		  private

		  def create_settings_config
				create_file "config/opsworks.yml", ""
		  	data = {"stack_id" => @stack_id, "app_id" => @app_id}
		    File.open("config/opsworks.yml", 'w') { |f| YAML.dump(data, f) }
		  end

		  def copy_rake_file
		    copy_file "oppsie.rake", "lib/tasks/oppsie.rake"
		  end

		end
	end
end
