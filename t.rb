project = {}
puts "Google Cloud PROJECT_ID:"
project[:project_id] = gets.chomp == "" ? "elsoul2" : gets.chomp
puts "Your APP name:"
project[:app] = gets.chomp == "" ? "grpc-td-cluster" : gets.chomp
puts "VPC Network Name:          (enter to default)"
project[:network] = gets.chomp == "" ? "default" : gets.chomp
puts "Instance MachineType:"
project[:machine_type] = gets.chomp == "" ? "custom-1-6656" : gets.chomp
puts "Zone:"
project[:zone] = gets.chomp == "" ? "us-central1-a" : gets.chomp
puts "Domain:"
project[:domain] = gets.chomp == "" ? "el-soul.com" : gets.chomp
puts "Google Application Credentials Path:"
project[:google_application_credentials] = gets.chomp == "" ? "./config/credentials.json" : gets.chomp

FileUtils.mkdir_p "config/initializers" unless File.directory? "config"
path = "config/initializers/rails-gke.rb"
File.open(path, "w") do |f|
  f.write <<~EOS
    Rails::Gke.configure do |config|
      config.project_id = "#{project[:project_id]}"
      config.app = "#{project[:app]}"
      config.network = "#{project[:network]}"
      config.machine_type = "#{project[:machine_type]}"
      config.zone = "#{project[:zone]}"
      config.domain = "#{project[:domain]}"
      config.google_application_credentials = "#{project[:google_application_credentials]}"
    end
  EOS
end
puts "You Are All Set!!"
puts "config at ./config/initializers/rails-gke.rb"