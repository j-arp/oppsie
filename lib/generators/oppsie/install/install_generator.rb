module Oppsie
	module Generators

		class InstallGenerator < Rails::Generators::Base
		  source_root File.expand_path("../templates", __FILE__)

		  #attr_reader :stack_id, :app_id

		  def initialize(runtime_args, runtime_options = {}, wat)
		    puts "init generator"
		    @stack_id = runtime_args[0]
		    @app_id = runtime_args[1]
		    super

		  end

		  def install
		  	puts "stack is #{@stack_id}"
		  	puts "app is #{@app_id}"
		  	puts "create yml config file"
		  	create_settings_config
		  	puts "isntall rake tasks"
		  	copy_rake_file
		  end

		  private

		  def create_settings_config

		  	puts "creating yml file"
			create_file "config/opsworks.yml", ""
		  	data = {"stack_id" => @stack_id, "app_id" => @app_id}
		    File.open("config/opsworks.yml", 'w') { |f| YAML.dump(data, f) }
		  end

		  def copy_rake_file
		  	puts "create rake file"
		    copy_file "oppsie.rake", "lib/tasks/oppsie.rake"
		  end


		  	def set_vars
		  		puts "set vars"
		  	end

		end




	end

end
