# Ruby on Rails GKE Deploy Kit

Ruby on Rails GKE Deploy Kit. You can deploy your Ruby on Rails on Google Kubernate Engine with https.

<p align="center">

  <a aria-label="Ruby logo" href="https://el-soul.com">
    <img src="https://badgen.net/badge/icon/Made%20by%20ELSOUL?icon=ruby&label&color=black&labelColor=black">
  </a>
  <br/>

  <a aria-label="Ruby Gem version" href="https://rubygems.org/gems/rails-gke">
    <img alt="" src="https://badgen.net/rubygems/v/rails-gke/latest">
  </a>
  <a aria-label="Downloads Number" href="https://rubygems.org/gems/rails-gke">
    <img alt="" src="https://badgen.net/rubygems/dt/rails-gke">
  </a>
  <a aria-label="License" href="https://github.com/elsoul/rails-gke/blob/master/LICENSE">
    <img alt="" src="https://badgen.net/badge/license/Apache/blue">
  </a>
</p>

## Dependency

1. Google SDK
[https://cloud.google.com/sdk/docs](https://cloud.google.com/sdk/docs)
2. Docker
[https://www.docker.com/](https://www.docker.com/)

## Installation

Add this line to your application's Gemfile:

```ruby
gem "rails-gke"
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install rails-gke

## Usage
Initialize Config

    $ rails_gke

This command will create `config/initializers/rails-gke.rb`

```ruby
Rails::Gke.configure do |config|
  config.project_id = ENV["project_id"] || "elsoul-project"
  config.app = ENV["app"] || "elsoul-app"
  config.network = ENV["network"] || "elsoul-network"
  config.machine_type = ENV["machine_type"] || "g1-small"
  config.zone = ENV["zone"] || "asia-northeast1"
  config.domain = ENV["DOMAIN"]
  config.google_application_credentials = ENV["GOOGLE_APPLICATION_CREDENTIALS"]
end
```
Set your environment as needed above.

Then create `yml` files by this running command

    $ create_yml

Now you can see 4 GKE yml files;

`deployment.yml`
`service.yml`
`secret.yml`
`ingress.yml`


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org/gems/rails-gke).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/elsoul/rails-gke. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [Apache-2.0 License](https://www.apache.org/licenses/LICENSE-2.0).

## Code of Conduct

Everyone interacting in the HotelPrice project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/elsoul/rails-gke/blob/master/CODE_OF_CONDUCT.md).