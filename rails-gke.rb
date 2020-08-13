## Config Example
# It's better to use ENV to define value.
Rails::Gke.configure do |config|
  config.project_id = "elsoul"
  config.app = "elsoul-api"
  config.network = "elsoul-blog"
  config.machine_type = "custom-1-6656"
  config.zone = "asia-northeast1"
end
