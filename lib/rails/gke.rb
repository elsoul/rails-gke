require "rails/gke/version"

module Rails
  module Gke
    class Error < StandardError; end
    class << self
      attr_accessor :configuration
    end

    def self.configure
      self.configuration ||= Configuration.new
      yield(configuration)
    end

    private

    class Configuration
      attr_accessor :project_id, :app, :network, :sub_network, :machine_type, :namespace, :global_ip

      def initialize
        @project_id = nil
        @app = nil
        @network = nil
        @sub_network = nil
        @machine_type = nil
        @namespace = nil
        @global_ip = nil
      end
    end
  end
end