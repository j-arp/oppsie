require "JSON"

namespace :oppsie do

  desc "task that is inherited that setups up instance vars"
  task :setup do
    set_config
  end

  desc "shows options for use"
  task :help do
    system "clear"

    puts "\n\n---------- How to use Oppsie ---------\n========================================\n\n"

    puts "DEPLOY:"
    puts "Task: oppsie:deploy      #pushes latest commits to github and deploys master branch to aws"
    puts "  Options: "
    puts "    branch={branch} #choose to deploy a different branch"
    puts "    migrate={true|false} #have opsworks run db:migrate during deployment"

    puts "\nSTATUS: "
    puts "Task: oppsie:status      #returns the json from Opsworks showing deployment settings and current status of last deployment"

    puts "\nRESTART: "
    puts "Task: oppsie:restart      #restarts the web server"

    puts "\n\n"
  end

  desc "update branch manually"
  task :set_app_branch => :setup do
    response = `aws opsworks update-app --app-id #{@app_id} --app-source '{ \"Revision\": \"#{branch}\"}'`
    msg("Setting branch in opsworks to #{branch}")
  end


  desc "restart webserver"
  task :restart => :setup  do

    msg "run command to restart"
    command_json = command(name="restart")
    response = run_deployment(command_json)
    puts response

  end

  desc "push a specific branch to github. will be included with the deploy task"
  task :push => :setup do

    puts "updating app #{@app_id} with branch #{branch}"

    begin
      system "git push origin #{branch}"
      rescue
        "\n\n---------- ERROR ------------------------\n  Pushing to github failed \n-----------------------------------------\n "
      end

  end

  desc "deploy a branch (or master as a default) to OpsWorks. This will push any changes to Github, update your application settings in opsworks to the given branch, start the deployment, change the applications brach back to master"
  task :deploy => :push do

    set_branch(branch)
    request_json = {"Name" => "deploy", "Args" => {"migrate" => [migrate?]}}
    response = run_deployment(request_json)

    set_branch("master")
  end

  desc "Will return the status of the last known deployment to Opsworks. Will put to the console the JSON response."
  task :status => :setup do
    status = read_config
    if status["last_deployment_id"]
      response = `aws opsworks describe-deployments --deployment-ids #{status["last_deployment_id"]}`
      puts response
    else
      puts "No status available. make sure a deployment was executed successfully"
    end
  end
end

  ############################################################


  def run_deployment(command)
    puts "running command: "
    puts command

    begin
      response = `aws opsworks --region us-east-1 create-deployment --stack-id #{@stack_id} --app-id #{@app_id} --command \'#{command.to_json}\'`
      response_json = JSON.parse(response)
      rescue
        puts " \n\n---------- ERROR ------------------------\n Response was not valid. Probably you did something really bad.\n------------------------------------------\n\n"
        response_json = {"DeploymentId" => nil}
      end

      update_deployment(response_json["DeploymentId"])
      response_json
  end




  #ACTION METHODS



  def command(name, options={})
    command_json = {"Name" => "#{name}", "Args" => options }
  end

  def set_branch(branch)
    msg "setting branch in opsworks to #{branch}"

    begin
          response = `aws opsworks update-app --app-id #{@app_id} --app-source '{ \"Revision\": \"#{branch}\"}'`
          msg "branch set!"
      rescue
        msg("Could not update opsworks app.", "error")
      end
  end


  def deploy
    puts "executing deployment"
    end




  def update_deployment(id)
    if id
      msg "write deployment"
      ops_file = File.join(Rails.root, 'config', 'opsworks.yml')
      data = YAML.load_file(ops_file)
      data["last_deployment_id"] = id
      File.open(ops_file, 'w') { |f| YAML.dump(data, f) }

      puts "Deployment has been recorded. You can now find the status by running oppsie:status"
   else
       puts msg("Deployment failed", "error")
   end
  end

  #HELPER METHODS

  def set_config
    ops_config = Hash.new
    ops_file = File.join(Rails.root, 'config', 'opsworks.yml')

    YAML.load(File.open(ops_file)).each do |key, value|
      ops_config[key.to_s] = value
    end if File.exists?(ops_file)

      @stack_id = ops_config["stack_id"]
      @app_id = ops_config["app_id"]
  end

  #REMOVE ASAP
  def read_config
    ops_config = Hash.new
    ops_file = File.join(Rails.root, 'config', 'opsworks.yml')

    YAML.load(File.open(ops_file)).each do |key, value|
      ops_config[key.to_s] = value
    end if File.exists?(ops_file)

    return ops_config
  end


  def migrate?
    msg "migrate dababase?"
    msg ENV["migrate"]
    ENV["migrate"] || "false"
  end


  def branch
     ENV["branch"] || "master"
  end


  def msg(msg, prefix="info")

    puts "\n\n-- #{prefix.upcase}:: -----------------------------"
    puts msg
    puts "-----------------------------------------\n"


  end

=begin

            "Command": {
                "Args": {},
                "Name": "update_custom_cookbooks"
              }
=end
