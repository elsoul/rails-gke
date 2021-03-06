require_relative "lib/rails/gke/version"

Gem::Specification.new do |spec|
  spec.name          = "rails-gke"
  spec.version       = Rails::Gke::VERSION
  spec.authors       = ["Fumitake Kawasaki"]
  spec.email         = ["fumitake.kawasaki@el-soul.com"]

  spec.summary       = "Ruby on Rails GKE Deploy Kit"
  spec.description   = "This gem is migrated to `souls` gem. Please go to `souls` gem."
  spec.homepage      = "https://github.com/elsoul/rails-gke"
  spec.license       = "Apache-2.0"
  spec.metadata = { "source_code_uri" => "https://github.com/elsoul/rails-gke" }
  spec.required_ruby_version = ">= 2.7.0"
  # spec.metadata["allowed_push_host"] = "https://hotel.el-soul.com"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/elsoul/rails-gke"
  spec.metadata["changelog_uri"] = "https://github.com/elsoul/rails-gke"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
