module Rails
  module Gke::Initialize
    class << self
      def config
        FileUtils.mkdir_p "config/initializers" unless File.directory? "config"
        File.open("config/initializers/rails-gke.rb", "w") do |f|
          text = <<~EOS
            Rails::Gke.configure do |config|
              config.project_id = ENV["PROJECT_ID"]
              config.app = ENV["APP"]
              config.network = ENV["NETWORK"]
              config.machine_type = ENV["MACHINE_TYPE"]
              config.zone = ENV["ZONE"]
              config.domain = ENV["DOMAIN"]
              config.google_application_credentials = ENV["GOOGLE_APPLICATION_CREDENTIALS"]
            end
          EOS
          f.write(text)
        end
      end

      def create_yml
        return "Error: Please Set Rails::Gke.configuration" if Rails::Gke.configuration.nil?
        puts "created deployment.yml" if self.deployment
        puts "created service.yml" if self.service
        puts "created secret.yml" if self.secret
        puts "created ingress.yml" if self.ingress
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
