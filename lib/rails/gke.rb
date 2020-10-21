require "rails/gke/version"
require "rails/gke/initialize"

module Rails
  module Gke
    class Error < StandardError; end
    class << self
      attr_accessor :configuration

      def create_network
        return "Error: Please Set Rails::Gke.configuration" if Rails::Gke.configuration.nil?
        system("gcloud compute networks create #{Rails::Gke.configuration.network}")
      end

      def create_cluster
        app = Rails::Gke.configuration.app
        network = Rails::Gke.configuration.network
        sub_network = Rails::Gke.configuration.network
        machine_type = Rails::Gke.configuration.machine_type
        zone = Rails::Gke.configuration.zone
        channel = Rails::Gke.configuration.channel
        system("gcloud container clusters create #{app} --region #{zone} \
          --machine-type #{machine_type} --enable-autorepair --enable-ip-alias --network #{network} --subnetwork #{sub_network} --num-nodes 2 --enable-autoscaling --min-nodes 1 --max-nodes 4 --tags=allow-health-checks --release-channel #{channel}")
      end

      def resize_cluster pool_name: "default-pool", node_num: 1
        app = Rails::Gke.configuration.app
        zone = Rails::Gke.configuration.zone
        system "gcloud container clusters resize #{app} --node-pool #{pool_name} --num-nodes #{node_num} --zone #{zone}"
      end

      def create_namespace
        app = Rails::Gke.configuration.app
        system("kubectl create namespace #{app}")
      end

      def create_ip
        ip_name = Rails::Gke.configuration.app.to_s + "-ip"
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

      def update_container version: "latest"
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

      def create_ssl
        system("gcloud compute ssl-certificates create #{Rails::Gke.configuration.app}-ssl --domains=#{Rails::Gke.configuration.domain} --global")
      end

      def update_proxy
        system("gcloud compute target-https-proxies update TARGET_PROXY_NAME \
        --ssl-certificates SSL_CERTIFICATE_LIST \
        --global-ssl-certificates \
        --global")
      end
    end

    def self.configure
      self.configuration ||= Configuration.new
      yield(configuration)
    end

    class Configuration
      attr_accessor :project_id, :app, :network, :machine_type, :zone, :domain, :google_application_credentials, :channel

      def initialize
        @project_id = nil
        @app = nil
        @network = nil
        @machine_type = nil
        @zone = nil
        @domain = nil
        @google_application_credentials = nil
        @channel = nil
      end
    end
  end
end
