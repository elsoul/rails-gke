RSpec.describe Rails::Gke do
  it "has a version number" do
    expect(Rails::Gke::VERSION).not_to be nil
  end

  describe "Configuration" do
    it "Should be able to set configuration" do
      Rails::Gke.configure do |config|
        config.project_id = "abc123"
      end

      expect(Rails::Gke.configuration.project_id).to eq "abc123"
    end
  end
end
