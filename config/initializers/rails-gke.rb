Rails::Gke.configure do |config|
  config.project_id = "PROJECT_ID"
  config.app = "APP-name"
  config.network = "NETWORK"
  config.machine_type = "MACHINE_TYPE"
  config.zone = "ZONE"
  config.domain = "DOMAIN"
  config.channel = "stable"
  config.google_application_credentials = "GOOGLE_APPLICATION_CREDENTIALS"
end
