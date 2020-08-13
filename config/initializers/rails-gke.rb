Rails::Gke.configure do |config|
  config.project_id = ENV["project_id"] || "elsoul-project"
  config.app = ENV["app"] || "elsoul-app"
  config.network = ENV["network"] || "elsoul-network"
  config.sub_network = ENV["sub_network"] || "elsoul-sub-network"
  config.machine_type = ENV["machine_type"] || "g1-small"
  config.zone = ENV["zone"] || "asia-northeast1"
end
