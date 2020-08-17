# Ruby on Rails GKE Deploy Kit

Ruby on Rails GKE Deploy Kit. You can deploy your Ruby on Rails on Google Kubernate Engine with ingress https.

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

## Configuration

Initialize Config

    $ rails_gke

This command will create `config/initializers/rails-gke.rb`

Sample Config

```ruby
# It's better to use ENV to define values.
Rails::Gke.configure do |config|
  config.project_id = "elsoul"
  config.app = "elsoul-api"
  config.network = "elsoul-blog"
  config.machine_type = "custom-1-6656"
  config.zone = "asia-northeast1"
  config.domain = "rails-gke.el-soul.com"
  config.google_application_credentials = "config/credentials.json"
end
```

Check if configuration set in console

```ruby
rails c
irb(main):002:0> Rails::Gke.configuration.nil?
=> false
```

Set your environment as needed above.

Then create `yml` files in rails console

```ruby
Rails::Gke::Initialize.create_yml
```

In console

```ruby
rails c
irb(main):001:0> Rails::Gke::Initialize.create_yml
=> true
```

Now you can see 4 GKE yml files;

`deployment.yml`
`service.yml`
`secret.yml`
`ingress.yml`

In `deployment.yml` you need to change your container version when you update your container.

`asia.gcr.io/project_id/app_name:0.0.1`

Also you need to set ENV.

And you can edit `secret.yml` as you needed.

Then create `rails task file`

```ruby
Rails::Gke::Initialize.create_task
```

In console

```ruby
rails c
irb(main):001:0> Rails::Gke::Initialize.create_task
=> true
```

This will create `lib/tasks/gke.rake` file.

Now you are ready to use all the command.

## Usage

Set GCP Project

    $ gcloud auth login
    $ gcloud config set project `your-project-id`

Please check `lib/tasks/gke.rake` file.
You can run gke command like this;

```ruby
rails gke:TASK_NAME
```

So let's deploy your rails application on Google Kubernates Engine.

1. Create VPC Network

```ruby
rails gke:create_network
```

2. Create Kubernate Cluster

```ruby
rails gke:create_cluster
```

3. Create Global IP

```ruby
rails gke:create_ip
```

4. Create namespace

```ruby
rails gke:create_namespace
```

5. Apply secret.yml 

```ruby
rails gke:apply_secret
```


6. Apply deployment.yml

```ruby
rails gke:apply_deployment
```

Check your GKE pods if its running well.

```ruby
rails gke:get_pods
```

Output

```
NAME                                      READY   STATUS    RESTARTS   AGE
elsoul-api-deployment-5dfb777c67-456js   1/1     Running   0          20s
elsoul-api-deployment-5dfb777c67-g8kwp   1/1     Running   0          20s
elsoul-api-deployment-5dfb777c67-x857m   1/1     Running   0          20s
```

If you can't see containers ready, you need to fix your container first.

7. Apply service.yml

```ruby
rails gke:apply_service
```

Check your GKE svc if its running well.

```ruby
rails gke:get_svc
```

Output

```
NAME                  TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)        AGE
elsoul-api-service   LoadBalancer   xx.xxx.x.xx   xx.xx.xxx.xxx   80:32321/TCP     1h
```

8. Apply ingress.yml

```ruby
rails gke:apply_ingress
```

Check your GKE ingress if its running well.

```ruby
rails gke:get_ingress
```

This will take serveral mins.
You need to set the IP address to A record in your domain management console once Ingress got IP ADDRESS

```
NAME                HOSTS                     ADDRESS         PORTS   AGE
https-elsoul-api   elsoul-api.el-soul.com   xx.xx.xxx.xxx   80      5d16h
```

9. Create LoadBalancer Frontend HTTPS




## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org/gems/rails-gke).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/elsoul/rails-gke. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [Apache-2.0 License](https://www.apache.org/licenses/LICENSE-2.0).

## Code of Conduct

Everyone interacting in the HotelPrice project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/elsoul/rails-gke/blob/master/CODE_OF_CONDUCT.md).
