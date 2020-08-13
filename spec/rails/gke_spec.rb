RSpec.describe Rails::Gke do
  it "has a version number" do
    expect(Rails::Gke::VERSION).not_to be nil
  end

  describe "Configuration" do
    it "Should be able to set configuration" do
      Rails::Gke.configure do |config|
        config.project_id = "abc123"
        config.app = "abc123"
        config.network = "abc123"
        config.sub_network = "abc123"
        config.machine_type = "abc123"
        config.zone = "abc123"
        config.domain = "abc123.com"
        config.google_application_credentials = "config/key.json"
      end

      expect(Rails::Gke.configuration.project_id).to eq "abc123"
    end
  end
end
