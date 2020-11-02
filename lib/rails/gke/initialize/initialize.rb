module Rails
  module Gke::Initialize
    class << self
      def config
        FileUtils.mkdir_p "config/initializers" unless File.directory? "config"
        path = "config/initializers/rails-gke.rb"
        File.open(path, "w") do |f|
          f.write <<~EOS
            Rails::Gke.configure do |config|
              config.project_id = "PROJECT_ID"
              config.app = "APP-name"
              config.network = "default"
              config.machine_type = "custom-1-6656"
              config.zone = "asia-northeast1"
              config.domain = "DOMAIN"
              config.channel = "stable"
              config.google_application_credentials = "GOOGLE_APPLICATION_CREDENTIALS"
            end
          EOS
        end
      end

      def create_yml
        return "Error: Please Set Rails::Gke.configuration" if Rails::Gke.configuration.nil?
        puts "created deployment.yml" if self.deployment
        puts "created service.yml" if self.service
        puts "created secret.yml" if self.secret
        puts "created ingress.yml" if self.ingress
      end

      def create_souls_task
        FileUtils.mkdir_p "app/tasks" unless File.directory? "app/tasks"
        path = "app/tasks/gke.rake"
        File.open(path, "w") do |f|
          f.write <<~EOS
            namespace :gke do
              task create_cluster: :environment do
                Rails::Gke.create_cluster
              end

              task add_backend_service: :environment do
                neg_name = Rails::Gke.set_network_group_list_env
                Rails::Gke.add_backend_service neg_name: neg_name
              end


              task create_td_default: :environment do
                Rails::Gke.create_health_check
                Rails::Gke.create_firewall_rule
                Rails::Gke.create_backend_service
                neg_name = Rails::Gke.set_network_group_list_env
                Rails::Gke.add_backend_service neg_name: neg_name
                Rails::Gke.create_url_map
                Rails::Gke.create_path_matcher
                Rails::Gke.create_target_grpc_proxy
                Rails::Gke.create_forwarding_rule
              end

              task create_td: :environment do
                app = "blog-service"
                health_check_name = app.to_s + "-hc"
                Rails::Gke.create_health_check health_check_name: health_check_name
                firewall_rule_name = app.to_s + "-allow-health-checks"
                Rails::Gke.create_firewall_rule firewall_rule_name: firewall_rule_name
                service_name = app.to_s + ""
                zone = Rails::Gke.configuration.zone

                Rails::Gke.create_backend_service service_name: service_name, health_check_name: health_check_name
                neg_name = "k8s1-87bf55a7-default-blog-service-8080-c7e834de"
                Rails::Gke.add_backend_service service_name: service_name, neg_name: neg_name, zone: zone

                url_map_name = app.to_s + "-url-map"
                Rails::Gke.create_url_map url_map_name: url_map_name, service_name: service_name
                path_matcher_name = app.to_s + "-path-mathcher"
                hostname = app.to_s + ""
                port = "5000"
                Rails::Gke.create_path_matcher url_map_name: url_map_name, service_name: service_name, path_matcher_name: path_matcher_name, hostname: hostname, port: port
                proxy_name = app.to_s + "-proxy"
                Rails::Gke.create_target_grpc_proxy proxy_name: proxy_name, url_map_name: url_map_name
                forwarding_rule_name = app.to_s + "-forwarding-rule"
                Rails::Gke.create_forwarding_rule forwarding_rule_name: forwarding_rule_name, proxy_name: proxy_name, port: port
              end

              task delete_td: :environment do
                app = "blog-service"
                health_check_name = app.to_s + "-hc"
                firewall_rule_name = app.to_s + "-allow-health-checks"
                service_name = app.to_s + ""
                url_map_name = app.to_s + "-url-map"
                proxy_name = app.to_s + "-proxy"
                forwarding_rule_name = app.to_s + "-forwarding-rule"

                Rails::Gke.delete_forwarding_rule forwarding_rule_name: forwarding_rule_name
                Rails::Gke.delete_target_grpc_proxy proxy_name: proxy_name
                Rails::Gke.delete_url_map url_map_name: url_map_name
                Rails::Gke.delete_backend_service service_name: service_name
                Rails::Gke.delete_health_check health_check_name: health_check_name
                Rails::Gke.delete_firewall_rule firewall_rule_name: firewall_rule_name
              end

              task get_neg_name: :environment do
                Rails::Gke.get_network_group_list
              end

              task set_neg_name: :environment do
                Rails::Gke.set_network_group_list_env
              end
            
              task delete_td_default: :environment do
                Rails::Gke.delete_forwarding_rule
                Rails::Gke.delete_target_grpc_proxy
                Rails::Gke.delete_url_map
                Rails::Gke.delete_backend_service
                Rails::Gke.delete_health_check
                Rails::Gke.delete_firewall_rule
                Rails::Gke.delete_cluster
                neg_name = Rails::Gke.set_network_group_list_env
                Rails::Gke.delete_network_group_list neg_name: neg_name
              end
            
              task :resize_cluster, [:pool_name, :node_num] => :environment do |_, args|
                pool_name = "default-pool" || args[:pool_name]
                node_num = 1 || args[:node_num]
                Rails::Gke.resize_cluster pool_name: pool_name, node_num: node_num
              end
            
              task create_namespace: :environment do
                Rails::Gke.create_namespace
              end
            
              task create_ip: :environment do
                Rails::Gke.create_ip
              end
            
              task apply_deployment: :environment do
                Rails::Gke.apply_deployment
              end
            
              task apply_service: :environment do
                Rails::Gke.apply_service
              end
            
              task apply_secret: :environment do
                Rails::Gke.apply_secret
              end
            
              task apply_ingress: :environment do
                Rails::Gke.apply_ingress
              end
            
              task delete_deployment: :environment do
                Rails::Gke.delete_deployment
              end
            
              task delete_service: :environment do
                Rails::Gke.delete_service
              end
            
              task delete_secret: :environment do
                Rails::Gke.delete_secret
              end
            
              task delete_ingress: :environment do
                Rails::Gke.delete_ingress
              end
            
              task test: :environment do
                Rails::Gke.run_test
              end
            
              task :update, [:version] => :environment do |_, args|
                Rails::Gke.update_container version: args[:version]
              end
            
              task apply_all: :environment do
                Rails::Gke.apply_deployment
                Rails::Gke.apply_service
                Rails::Gke.apply_secret
                Rails::Gke.apply_ingress
              end
            
              task delete_all: :environment do
                Rails::Gke.delete_deployment
                Rails::Gke.delete_service
                Rails::Gke.delete_secret
                Rails::Gke.delete_ingress
              end
            
              task get_pods: :environment do
                Rails::Gke.get_pods
              end
            
              task get_svc: :environment do
                Rails::Gke.get_svc
              end
            
              task get_ingress: :environment do
                Rails::Gke.get_ingress
              end
            
              task get_clusters: :environment do
                Rails::Gke.get_clusters
              end
            
              task get_current_cluster: :environment do
                Rails::Gke.get_current_cluster
              end
            
              task :use_context, [:cluster] => :environment do |_, args|
                Rails::Gke.use_context cluster: args[:cluster]
              end
            
              task get_credentials: :environment do
                Rails::Gke.get_credentials
              end
            end
          EOS
        end
        true
      rescue StandardError => error
        puts error
        false
      end

      def create_rails_task
        FileUtils.mkdir_p "lib/tasks" unless File.directory? "lib/tasks"
        path = "lib/tasks/gke.rake"
        File.open(path, "w") do |f|
          f.write <<~EOS
            namespace :gke do
              task create_cluster: :environment do
                Rails::Gke.create_cluster
              end

              task add_backend_service: :environment do
                neg_name = Rails::Gke.set_network_group_list_env
                Rails::Gke.add_backend_service neg_name: neg_name
              end


              task create_td_default: :environment do
                Rails::Gke.create_health_check
                Rails::Gke.create_firewall_rule
                Rails::Gke.create_backend_service
                neg_name = Rails::Gke.set_network_group_list_env
                Rails::Gke.add_backend_service neg_name: neg_name
                Rails::Gke.create_url_map
                Rails::Gke.create_path_matcher
                Rails::Gke.create_target_grpc_proxy
                Rails::Gke.create_forwarding_rule
              end

              task create_td: :environment do
                app = "blog-service"
                health_check_name = app.to_s "-hc"
                Rails::Gke.create_health_check health_check_name: health_check_name
                firewall_rule_name = app.to_s "-allow-health-checks"
                Rails::Gke.create_firewall_rule firewall_rule_name: firewall_rule_name
                service_name = app.to_s ""
                zone = Rails::Gke.configuration.zone

                Rails::Gke.create_backend_service service_name: service_name, health_check_name: health_check_name
                neg_name = "k8s1-87bf55a7-default-blog-service-8080-c7e834de"
                Rails::Gke.add_backend_service service_name: service_name, neg_name: neg_name, zone: zone

                url_map_name = app.to_s "-url-map"
                Rails::Gke.create_url_map url_map_name: url_map_name, service_name: service_name
                path_matcher_name = app.to_s "-path-mathcher"
                hostname = app.to_s ""
                port = "5000"
                Rails::Gke.create_path_matcher url_map_name: url_map_name, service_name: service_name, path_matcher_name: path_matcher_name, hostname: hostname, port: port
                proxy_name = app.to_s "-proxy"
                Rails::Gke.create_target_grpc_proxy proxy_name: proxy_name, url_map_name: url_map_name
                forwarding_rule_name = app.to_s "-forwarding-rule"
                Rails::Gke.create_forwarding_rule forwarding_rule_name: forwarding_rule_name, proxy_name: proxy_name, port: port
              end

              task delete_td: :environment do
                app = "blog-service"
                health_check_name = app.to_s "-hc"
                firewall_rule_name = app.to_s "-allow-health-checks"
                service_name = app.to_s ""
                url_map_name = app.to_s "-url-map"
                proxy_name = app.to_s "-proxy"
                forwarding_rule_name = app.to_s "-forwarding-rule"

                Rails::Gke.delete_forwarding_rule forwarding_rule_name: forwarding_rule_name
                Rails::Gke.delete_target_grpc_proxy proxy_name: proxy_name
                Rails::Gke.delete_url_map url_map_name: url_map_name
                Rails::Gke.delete_backend_service service_name: service_name
                Rails::Gke.delete_health_check health_check_name: health_check_name
                Rails::Gke.delete_firewall_rule firewall_rule_name: firewall_rule_name
              end

              task get_neg_name: :environment do
                Rails::Gke.get_network_group_list
              end

              task set_neg_name: :environment do
                Rails::Gke.set_network_group_list_env
              end
            
              task delete_td_default: :environment do
                Rails::Gke.delete_forwarding_rule
                Rails::Gke.delete_target_grpc_proxy
                Rails::Gke.delete_url_map
                Rails::Gke.delete_backend_service
                Rails::Gke.delete_health_check
                Rails::Gke.delete_firewall_rule
                Rails::Gke.delete_cluster
                neg_name = Rails::Gke.set_network_group_list_env
                Rails::Gke.delete_network_group_list neg_name: neg_name
              end
            
              task :resize_cluster, [:pool_name, :node_num] => :environment do |_, args|
                pool_name = "default-pool" || args[:pool_name]
                node_num = 1 || args[:node_num]
                Rails::Gke.resize_cluster pool_name: pool_name, node_num: node_num
              end
            
              task create_namespace: :environment do
                Rails::Gke.create_namespace
              end
            
              task create_ip: :environment do
                Rails::Gke.create_ip
              end
            
              task apply_deployment: :environment do
                Rails::Gke.apply_deployment
              end
            
              task apply_service: :environment do
                Rails::Gke.apply_service
              end
            
              task apply_secret: :environment do
                Rails::Gke.apply_secret
              end
            
              task apply_ingress: :environment do
                Rails::Gke.apply_ingress
              end
            
              task delete_deployment: :environment do
                Rails::Gke.delete_deployment
              end
            
              task delete_service: :environment do
                Rails::Gke.delete_service
              end
            
              task delete_secret: :environment do
                Rails::Gke.delete_secret
              end
            
              task delete_ingress: :environment do
                Rails::Gke.delete_ingress
              end
            
              task test: :environment do
                Rails::Gke.run_test
              end
            
              task :update, [:version] => :environment do |_, args|
                Rails::Gke.update_container version: args[:version]
              end
            
              task apply_all: :environment do
                Rails::Gke.apply_deployment
                Rails::Gke.apply_service
                Rails::Gke.apply_secret
                Rails::Gke.apply_ingress
              end
            
              task delete_all: :environment do
                Rails::Gke.delete_deployment
                Rails::Gke.delete_service
                Rails::Gke.delete_secret
                Rails::Gke.delete_ingress
              end
            
              task get_pods: :environment do
                Rails::Gke.get_pods
              end
            
              task get_svc: :environment do
                Rails::Gke.get_svc
              end
            
              task get_ingress: :environment do
                Rails::Gke.get_ingress
              end
            
              task get_clusters: :environment do
                Rails::Gke.get_clusters
              end
            
              task get_current_cluster: :environment do
                Rails::Gke.get_current_cluster
              end
            
              task :use_context, [:cluster] => :environment do |_, args|
                Rails::Gke.use_context cluster: args[:cluster]
              end
            
              task get_credentials: :environment do
                Rails::Gke.get_credentials
              end
            end          
          EOS
        end
        true
      rescue StandardError => error
        puts error
        false
      end

      def deployment
        return "Error: Please Set Rails::Gke.configuration" if Rails::Gke.configuration.nil?
        return "Error: Already Exsit deployment.yml" if File.file? "deployment.yml"
        File.open("deployment.yml", "w") do |f|
          yml = <<~EOS
            apiVersion: extensions/v1beta1
            kind: Deployment
            metadata:
              name: #{Rails::Gke.configuration.app}-deployment
            spec:
              replicas: 3
              template:
                metadata:
                  labels:
                    app: #{Rails::Gke.configuration.app}
                spec:
                  containers:
                    - name: #{Rails::Gke.configuration.app}
                      image: asia.gcr.io/#{Rails::Gke.configuration.project_id}/#{Rails::Gke.configuration.app}:0.0.1
                      ports:
                        - containerPort: 3000
                          protocol: TCP
                      livenessProbe:
                        httpGet:
                          path: /
                          port: 3000
                        initialDelaySeconds: 30
                        timeoutSeconds: 1
                      readinessProbe:
                        httpGet:
                          path: /
                          port: 3000
                        initialDelaySeconds: 30
                        timeoutSeconds: 1
                      env:
                        - name: DB_HOST
                          valueFrom:
                            secretKeyRef:
                              name: #{Rails::Gke.configuration.app}-secret
                              key: db_host
                        - name: DB_USER
                          valueFrom:
                            secretKeyRef:
                              name: #{Rails::Gke.configuration.app}-secret
                              key: db_user
                        - name: DB_PW
                          valueFrom:
                            secretKeyRef:
                              name: #{Rails::Gke.configuration.app}-secret
                              key: db_pw
          EOS
          f.write(yml)
        end
        true
      rescue
        false
      end

      def service
        return "Error: Please Set Rails::Gke.configuration" if Rails::Gke.configuration.nil?
        return "Error: Already Exsit service.yml" if File.file? "service.yml"
        File.open("service.yml", "w") do |f|
          yml = <<~EOS
            kind: Service
            apiVersion: v1
            metadata:
              name: #{Rails::Gke.configuration.app}-service
            spec:
              selector:
                app: #{Rails::Gke.configuration.app}
              type: LoadBalancer
              ports:
                - name: http
                  protocol: TCP
                  port: 80
                  targetPort: 3000
          EOS
          f.write(yml)
        end
        true
      rescue
        false
      end

      def ingress
        return "Error: Please Set Rails::Gke.configuration" if Rails::Gke.configuration.nil?
        return "Error: Already Exsit ingress.yml" if File.file? "ingress.yml"
        File.open("ingress.yml", "w") do |f|
          yml = <<~EOS
            apiVersion: extensions/v1beta1
            kind: Ingress
            metadata:
              name: https-#{Rails::Gke.configuration.app}
              annotations:
                kubernetes.io/ingress.global-static-ip-name: https-#{Rails::Gke.configuration.app}
                networking.gke.io/managed-certificates: #{Rails::Gke.configuration.app}-secret
            spec:
              rules:
              - host: #{Rails::Gke.configuration.domain}
                http:
                  paths:
                  - backend:
                      serviceName: #{Rails::Gke.configuration.app}-service
                      servicePort: 80

          EOS
          f.write(yml)
        end
        true
      rescue
        false
      end

      def grpc_service_deployment
        return "Error: Please Set Rails::Gke.configuration" if Rails::Gke.configuration.nil?
        return "Error: Already Exsit deployment.yml" if File.file? "deployment.yml"
        path = "secret.yml"
        File.open(path, "w") do |f|
          f.write <<~EOS
            apiVersion: v1
            kind: Service
            metadata:
              name: #{Rails::Gke.configuration.service1}
              annotations:
                cloud.google.com/neg: '{"exposed_ports":{"8080":{}}}'
            spec:
              ports:
              - port: 8080
                name: #{Rails::Gke.configuration.service1}
                protocol: TCP
                targetPort: 50051
              selector:
                run: #{Rails::Gke.configuration.service1}
              type: ClusterIP

            ---
            apiVersion: extensions/v1beta1
            kind: Deployment
            metadata:
              labels:
                run: #{Rails::Gke.configuration.service1}
              name: #{Rails::Gke.configuration.service1}
            spec:
              replicas: 2
              template:
                metadata:
                  labels:
                    run: #{Rails::Gke.configuration.service1}
                spec:
                  containers:
                  - image: asia.gcr.io/#{Rails::Gke.configuration.project_id}/#{Rails::Gke.configuration.service1}:0.0.1
                    name: #{Rails::Gke.configuration.service1}
                    ports:
                    - protocol: TCP
                      containerPort: 50051
          EOS
        end
        true
      rescue
        false
      end

      def secret
        return "Error: Please Set Rails::Gke.configuration" if Rails::Gke.configuration.nil?
        return "Error: Already Exsit secret.yml" if File.file? "secret.yml"
        File.open("secret.yml", "w") do |f|
          yml = <<~EOS
            apiVersion: v1
            kind: Secret
            metadata:
              name: #{Rails::Gke.configuration.app}-secret
            type: Opaque
            data:
              db_user: dXNlcg==
              db_pw: cGFzc3dvcmQ=
              db_host: bG9jYWxob3N0
          EOS
          f.write(yml)
        end
        true
      rescue
        false
      end
    end
  end
end
