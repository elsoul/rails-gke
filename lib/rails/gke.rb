require "rails/gke/version"

module Rails
  module Gke
    class Error < StandardError; end
    class << self
      attr_accessor :configuration
    end

    def create_cluster
      network = Rails::Gke.configuration.network
      sub_network = Rails::Gke.configuration.sub_network
      machine_type = Rails::Gke.configuration.machine_type
      system("gcloud container clusters create graphql-api-cluster --region asia-northeast1 --num-nodes 1 \
        --machine-type #{machine_type} --enable-autorepair --enable-ip-alias --network #{network} --subnetwork #{sub_network}")
    end

    def create_namespace
    end

    def create_ip
    end

    def apply_deployment
    end

    def apply_secret
    end

    def apply_service
    end

    def apply_ingress
    end

    def delete_deployment
    end

    def delete_secret
    end

    def delete_service
    end

    def delete_ingress
    end

    def update_container
    end

    def get_pods
    end

    def get_svc
    end

    def get_ingress
    end

    def run_test
    end

    def self.configure
      self.configuration ||= Configuration.new
      yield(configuration)
    end

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
