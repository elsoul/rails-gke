module Rails
  module Gke::Initialize
    class << self
      def config
        FileUtils.mkdir_p "config/initializers" unless File.directory? "config"
        path = "config/initializers/rails-gke.rb"
        File.open(path, "w") do |f|
          f.write <<~EOS
            Rails::Gke.configure do |config|
              config.project_id = "your-PROJECT_ID"
              config.app = "your-APP-name"
              config.network = "your-NETWORK"
              config.machine_type = "your-MACHINE_TYPE"
              config.zone = "your-ZONE"
              config.domain = "your-DOMAIN"
              config.google_application_credentials = "your-GOOGLE_APPLICATION_CREDENTIALS"
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

      def create_task
        return "Error: Please Set Rails::Gke.configuration" if Rails::Gke.configuration.nil?
        FileUtils.mkdir_p "lib/tasks" unless File.directory? "lib/tasks"
        return "Error: Already Exsit lib/tasks/gke.rake" if File.file? "lib/tasks/gke.rake"
        File.open("lib/tasks/gke.rake", "w") do |f|
          task = <<~EOS
            namespace :gke do
              task create_cluster: :environment do
                Rails.Gke.create_cluster
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
          f.write(task)
        end
        true
      rescue
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
