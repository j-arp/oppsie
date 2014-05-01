namespace :oppsie do

  desc "push specific branch to github"
  task :push do
    settings = read_config
    options = {app_id: settings["app_id"]}

    if ENV["branch"]
      options[:branch] = ENV["branch"]
    else
      options[:branch] = "master"
    end

    puts "updating app #{options[:app_id]}"
    begin
      system "git push origin #{options[:branch]}"
      rescue
        "ERROR:: Pushing to github failed"
      end

  end

  task :deploy => :push do
    settings = read_config
    puts "deploying branch #{ENV["branch"]} to opsworks "
    deploy(settings["stack_id"], settings["app_id"], ENV["branch"])
  end

  task :status do
    status = read_config
    if status["last_deployment_id"]
      response = `aws opsworks describe-deployments --deployment-ids #{status["last_deployment_id"]}`
      puts response
    else
      puts "No status available. make sure a deployment was executed successfully"
    end
  end
end



def read_config
  ops_config = Hash.new
  ops_file = File.join(Rails.root, 'config', 'opsworks.yml')

  YAML.load(File.open(ops_file)).each do |key, value|
    ops_config[key.to_s] = value
  end if File.exists?(ops_file)

  return ops_config
end


  def deploy(stack_id, app_id, branch)
    puts "updating aws deployment to use branch #{branch}"
    begin
      system "aws opsworks update-app --app-id #{app_id} --app-source '{ \"Revision\": \"#{branch}\"}'"
      rescue
        puts "ERROR:: Could not update opsworks app"
      end
    if ENV["migrate"]
      puts "running rake db:migrate as well"
    end

    puts "executing deployment"
    begin
      response = `aws opsworks --region us-east-1 create-deployment --stack-id #{stack_id} --app-id #{app_id} --command \'{"Name":"deploy", "Args":{"migrate":["fa;se"]}}\'`
      response_json = JSON.parse(response)
      rescue
        puts "response was not valid. Probably you did something really bad."
        response_json = {"DeploymentId" => nil}
      end

    puts "returning deployment settings to use master"
    system "aws opsworks update-app --app-id #{app_id} --app-source '{ \"Revision\": \"master\"}'"

    update_deployment(response_json["DeploymentId"])
    puts "you can now check deployment status by running 'rake aws:status'"

  end


  def update_deployment(id)
    if id
      puts "write deployment"
      ops_file = File.join(Rails.root, 'config', 'opsworks.yml')
      data = YAML.load_file(ops_file)
      data["last_deployment_id"] = id
      File.open(ops_file, 'w') { |f| YAML.dump(data, f) }
   else
    puts "ERROR:: Deployment failed"
   end
  end
