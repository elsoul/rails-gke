require "rails/gke/version"

module Rails
  module Gke
    class Error < StandardError; end
    class << self
      attr_accessor :configuration

      def start
        File.new "development.yml"
      end

      def create_cluster
        network = Rails::Gke.configuration.network
        sub_network = Rails::Gke.configuration.sub_network
        machine_type = Rails::Gke.configuration.machine_type
        zone = Rails::Gke.configuration.zone
        system("gcloud container clusters create graphql-api-cluster --region #{zone} --num-nodes 1 \
          --machine-type #{machine_type} --enable-autorepair --enable-ip-alias --network #{network} --subnetwork #{sub_network}")
      end

      def create_namespace
        namespace = Rails::Gke.configuration.namespace
        system("kubectl create namespace #{namespace}")
      end

      def create_ip
        ip_name = Rails::Gke.configuration.global_ip
        system("gcloud compute addresses create #{ip_name} --global")
      end

      def apply_deployment
        app = Rails::Gke.configuration.app
        system("kubectl apply -f deployment.yml --namespace=#{app}")
      end

      def apply_secret
        app = Rails::Gke.configuration.app
        system("kubectl apply -f secret.yml --namespace=#{app}")
      end

      def apply_service
        app = Rails::Gke.configuration.app
        system("kubectl apply -f service.yml --namespace=#{app}")
      end

      def apply_ingress
        app = Rails::Gke.configuration.app
        system("kubectl apply -f ingress.yml --namespace=#{app}")
      end

      def delete_deployment
        app = Rails::Gke.configuration.app
        system("kubectl delete -f deployment.yml --namespace=#{app}")
      end

      def delete_secret
        app = Rails::Gke.configuration.app
        system("kubectl delete -f secret.yml --namespace=#{app}")
      end

      def delete_service
        app = Rails::Gke.configuration.app
        system("kubectl delete -f service.yml --namespace=#{app}")
      end

      def delete_ingress
        app = Rails::Gke.configuration.app
        system("kubectl delete -f ingress.yml --namespace=#{app}")
      end

      def update_container version: "0.0.1"
        app = Rails::Gke.configuration.app
        project_id = Rails::Gke.configuration.project_id
        system("docker build . -t #{app}:#{version}")
        system("docker tag #{app}:#{version} asia.gcr.io/#{project_id}/#{app}:#{version}")
        system("docker push asia.gcr.io/#{project_id}/#{app}:#{version}")
      end

      def get_pods
        app = Rails::Gke.configuration.app
        system("kubectl get pods --namespace=#{app}")
      end

      def get_svc
        app = Rails::Gke.configuration.app
        system("kubectl get svc #{app}-service --namespace=#{app}")
      end

      def get_ingress
        app = Rails::Gke.configuration.app
        system("kubectl get ingress --namespace=#{app}")
      end

      def run_test
        app = Rails::Gke.configuration.app
        system("docker rm -f web")
        system("docker build . -t #{app}:latest")
        system("docker run --name web -it --env-file $PWD/.local_env -p 3000:3000 #{app}:latest")
      end

      def get_clusters
        system("kubectl config get-clusters")
      end

      def get_current_cluster
        system("kubectl config current-context")
      end

      def use_context cluster:
        system("kubectl config use-context #{cluster}")
      end

      def get_credentials
        app = Rails::Gke.configuration.app
        zone = Rails::Gke.configuration.zone
        system("gcloud container clusters get-credentials #{app} -cluster --zone #{zone}")
      end
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
        @zone = nil
      end
    end
  end
end
