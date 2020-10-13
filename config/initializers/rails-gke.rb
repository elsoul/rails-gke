Rails::Gke.configure do |config|
  config.project_id = "your-PROJECT_ID"
  config.app = "your-APP-name"
  config.network = "your-NETWORK"
  config.machine_type = "your-MACHINE_TYPE"
  config.zone = "your-ZONE"
  config.domain = "your-DOMAIN"
  config.google_application_credentials = "your-GOOGLE_APPLICATION_CREDENTIALS"
end
