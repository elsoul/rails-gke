require "rails/gke/version"
require "rails/gke/initialize"

module Rails
  module Gke
    class Error < StandardError; end
    class << self
      attr_accessor :configuration

      def delete_forwarding_rule forwarding_rule_name: "grpc-gke-forwarding-rule"
        system "gcloud compute -q forwarding-rules delete #{forwarding_rule_name} --global"
      end

      def create_forwarding_rule forwarding_rule_name: "grpc-gke-forwarding-rule", proxy_name: "grpc-gke-proxy", port: 8000
        system "gcloud compute -q forwarding-rules create #{forwarding_rule_name} \
                --global \
                --load-balancing-scheme=INTERNAL_SELF_MANAGED \
                --address=0.0.0.0 \
                --target-grpc-proxy=#{proxy_name} \
                --ports #{port} \
                --network #{Rails::Gke.configuration.network}"
      end

      def delete_target_grpc_proxy proxy_name: "grpc-gke-proxy"
        system "gcloud compute -q target-grpc-proxies delete #{proxy_name}"
      end

      def create_target_grpc_proxy proxy_name: "grpc-gke-proxy", url_map_name: "grpc-gke-url-map"
        system "gcloud compute -q target-grpc-proxies create #{proxy_name} \
                --url-map #{url_map_name} \
                --validate-for-proxyless"
      end

      def create_path_matcher url_map_name: "grpc-gke-url-map", service_name: "grpc-gke-helloworld-service", path_matcher_name: "grpc-gke-path-matcher", hostname: "helloworld-gke", port: "8000"
        system "gcloud compute -q url-maps add-path-matcher #{url_map_name} \
                --default-service #{service_name} \
                --path-matcher-name #{path_matcher_name} \
                --new-hosts #{hostname}:#{port}"
      end

      def delete_url_map url_map_name: "grpc-gke-url-map"
        system "gcloud compute -q url-maps delete #{url_map_name}"
      end

      def create_url_map url_map_name: "grpc-gke-url-map", service_name: "grpc-gke-helloworld-service"
        system "gcloud compute -q url-maps create #{url_map_name} \
                --default-service #{service_name}"
      end

      def add_backend_service service_name: "grpc-gke-helloworld-service", zone: "us-central1-a", neg_name: ""
        system "gcloud compute -q backend-services add-backend #{service_name} \
                --global \
                --network-endpoint-group #{neg_name} \
                --network-endpoint-group-zone #{zone} \
                --balancing-mode RATE \
                --max-rate-per-endpoint 5"
      end

      def delete_backend_service service_name: "grpc-gke-helloworld-service"
        system "gcloud compute -q backend-services delete #{service_name} --global"
      end

      def create_backend_service service_name: "grpc-gke-helloworld-service", health_check_name: "grpc-gke-helloworld-hc"
        system "gcloud compute -q backend-services create #{service_name} \
                --global \
                --load-balancing-scheme=INTERNAL_SELF_MANAGED \
                --protocol=GRPC \
                --health-checks #{health_check_name}"
      end

      def delete_firewall_rule firewall_rule_name: "grpc-gke-allow-health-checks"
        system "gcloud compute -q firewall-rules delete #{firewall_rule_name}"
      end

      def create_firewall_rule firewall_rule_name: "grpc-gke-allow-health-checks"
        system "gcloud compute -q firewall-rules create #{firewall_rule_name} \
                --network #{Rails::Gke.configuration.network} \
                --action allow \
                --direction INGRESS \
                --source-ranges 35.191.0.0/16,130.211.0.0/22 \
                --target-tags allow-health-checks \
                --rules tcp:50051"
      end

      def delete_health_check health_check_name: "grpc-gke-helloworld-hc"
        system "gcloud compute -q health-checks delete #{health_check_name}"
      end

      def create_health_check health_check_name: "grpc-gke-helloworld-hc"
        system "gcloud compute -q health-checks create grpc #{health_check_name} --use-serving-port"
      end

      def create_network
        return "Error: Please Set Rails::Gke.configuration" if Rails::Gke.configuration.nil?
        system("gcloud compute networks create #{Rails::Gke.configuration.network}")
      end

      def get_network_group_list
        system "gcloud compute network-endpoint-groups list"
      end

      def create_network_group
        app = Rails::Gke.configuration.app
        network = Rails::Gke.configuration.network
        sub_network = Rails::Gke.configuration.network
        system("gcloud compute network-endpoint-groups create #{app} \
                --default-port=0 \
                --network #{network} \
                --subnet #{sub_network} \
                --global")
      end

      def set_network_group_list_env
        app = Rails::Gke.configuration.app
        system "NEG_NAME=$(gcloud compute network-endpoint-groups list | grep #{app} | awk '{print $1}')"
        `echo $NEG_NAME`
      end

      def delete_network_group_list neg_name: ""
        system "gcloud compute network-endpoint-groups delete #{neg_name} --zone #{Rails::Gke.configuration.zone} -q"
      end

      def delete_cluster cluster_name: "grpc-td-cluster"
        system "gcloud container clusters delete #{cluster_name} --zone #{Rails::Gke.configuration.zone} -q"
      end

      def create_cluster
        app = Rails::Gke.configuration.app
        network = Rails::Gke.configuration.network
        sub_network = Rails::Gke.configuration.network
        machine_type = Rails::Gke.configuration.machine_type
        zone = Rails::Gke.configuration.zone
        system("gcloud container clusters create #{app} \
                --network #{network} \
                --subnetwork #{sub_network} \
                --zone #{zone} \
                --scopes=https://www.googleapis.com/auth/cloud-platform \
                --machine-type #{machine_type} \
                --enable-autorepair \
                --enable-ip-alias \
                --num-nodes 2 \
                --enable-autoscaling \
                --min-nodes 1 \
                --max-nodes 4 \
                --tags=allow-health-checks")
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
        system("kubectl get svc --namespace=#{app}")
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
