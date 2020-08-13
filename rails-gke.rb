Rails::Gke.configure do |config|
  config.project_id = ENV["project_id"]
  config.app = ENV["app"]
  config.network = ENV["network"]
  config.sub_network = ENV["sub_network"]
  config.machine_type = ENV["machine_type"]
  config.namespace = ENV["namespace"]
  config.global_ip = ENV["global_ip"]
  config.zone = ENV["zone"]
end
