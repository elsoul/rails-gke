require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "yaml"
require "erb"
require "logger"
require "rails/gke"

desc "Generate gke.rake file in lib/tasks directory"
task :gen_task do
  puts Rails::Gke::Initialize.create_task
end

RSpec::Core::RakeTask.new(:spec)

task :default => :spec
