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
