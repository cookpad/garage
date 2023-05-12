# Garage
[![Ruby](https://github.com/cookpad/garage/actions/workflows/main.yml/badge.svg)](https://github.com/cookpad/garage/actions/workflows/main.yml)
[![Gem Version](https://badge.fury.io/rb/the_garage.svg)](https://badge.fury.io/rb/the_garage)

Rails framework to add RESTful hypermedia API to your application.

## Gem name has been changed!
We renamed gem name `the_garage` from version 2.0.0. Please update your Gemfile.

## What Is It?

Garage provides a simple, Hypermedia friendly RESTful API to your Rails application using its native RESTful routes. Garage provides a descriptive way to serve your ActiveRecord models, as well as plain old Ruby objects as JSON-based resources.

Garage supports OAuth 2 authorizations via Doorkeeper (more extensions to come), and provides resource-based access controls.

## Quickstart

In `Gemfile`:

```ruby
# Notice this gem has "the_" prefix for gem name.
gem 'the_garage'
```

In your Rails model class:

```ruby
class Employee < ActiveRecord::Base
  include Garage::Representer
  include Garage::Authorizable

  belongs_to :division
  has_many :projects
  property :id
  property :title
  property :first_name
  property :last_name

  property :division, selectable: true
  collection :projects, selectable: true

  link(:division) { division_path(division) }
  link(:projects) { employee_projects_path(self) }

  def self.build_permissions(perms, other, target)
    perms.permits! :read
  end
end
```

In your controller classes:

```ruby
class ApplicationController < ActionController::Base
  include Garage::ControllerHelper

  # ...
end

class EmployeesController < ApplicationController
  include Garage::RestfulActions

  def require_resources
    @resources = Employee.all
  end
end
```

Resources are rendered with [respond_with (responders gem)](https://github.com/heartcombo/responders).
Additional options can be passed to respond_with by implementing `respond_with_resources_options` (index action)
and `respond_with_resource_options` (show, update destroy actions).

Available options
* `:paginate` - (Boolean) Enable pagination when `true`. Paginates with the `per_page` and `page` params
* `:per_page` - (Integer) value for default number of resources per page when paginating
* `:max_per_page` - (Integer) Maximum resources per page, irrespective of requested per_page
* `:hard_limit` - (Integer) Limit of retrievable records when paginating. Also hides total records.
* `:distinct_by` - (Symbol) Specify a property to count by for total page count
* `:to_resource_options` - (Hash) Options to pass as argument to `to_resource(options)`

## Create decorator for your AR models
With not small application, you may add a presentation layer to build API responses.
Define a decorator class with `Resource` suffix and define `#to_resource` in
your AR model.

```ruby
class User < ActiveRecord::Base
  def to_resource
    UserResource.new(self)
  end
end

class UserResource
  include Garage::Representer
  include Garage::Authorizable

  property :id
  property :name
  property :email

  delegate :id, :name, :email, to: :@model

  def initialize(model)
    @model = model
  end
end
```

## Advanced Configurations

In `config/initializers/garage.rb`:

```ruby
Garage.configure {}

# Optional
Rails.application.config.to_prepare do
  Garage::TokenScope.configure do
    register :public, desc: "accessing publicly available data" do
      access :read, Recipe
    end

    register :read_post, desc: "reading blog post" do
      access :read, Post
    end
  end
end

# If you want to use different authentication/authorization logic.
Garage.configuration.strategy = Garage::Strategy::AuthServer
```

The following authentication strategies are available.

- `Garage::Strategy::NoAuthentication` - Does not authenticate request and
    does not verify permission and access on resource operation. For non-public,
    internal-use Garage application.
- `Garage::Strategy::Test` - Trust request thoroughly, and build access token
    from request headers. For testing or prototyping.
- `Garage::Strategy::Doorkeeper` - Authenticate request with doorkeeper gem.
    To use this strategy, bundle [garage-doorkeeper gem](https://github.com/cookpad/garage-doorkeeper).
- `Garage::Strategy::AuthServer` - Delegate authentication to OAuth server.
    This auth strategy has configurations.

## Delegate Authentication/Authorization to your OAuth server

To delegate auth to your OAuth server, use `Garage::Strategy::AuthServer` strategy.
Then configure auth server strategy:

- `Garage.configuration.auth_server_url` - A full url of your OAuth server's
    access token validation endpoint. i.e. `https://example.com/token`.
- `Garage.configuration.auth_server_host` - A host header value to request to
    your OAuth server. Can be empty.
- `Garage.configuration.auth_server_timeout` - A read timeout second. Default
    is 1 second.

The OAuth server must response a json with following structure.

- `token` (string, null) - OAuth access token value.
- `token_type` (string) - OAuth access token value. i.e. `bearer` type.
- `scope` (string) - OAuth scopes separated by spaces. i.e. `public read_user`.
- `application_id` (integer) - OAuth application id of the access token.
- `resource_owner_id` (integer, null) - Resource owner id of the access token.
- `expired_at` (string, null) - Expire datetime with string representation.
- `revoked_at` (string, null) - Revoked datetime with string representation.

When requested access token is invalid, OAuth server must response 401.

## Customize Authentication/Authorization

Garage supports customizable Authentication/Authorization strategy.
The Strategy has some conventions to follow.

- Offer OAuth access token via `access_token` method. With no access token case
    (does not authenticate request) `access_token` should return `nil`.
- Register `verify_auth` hook as before filter in `included` block if
    authenticate request. Or register custom authentication hook. The custom
    authentication hook should response unauthorized using
    `unauthorized_render_options` when fails to authenticate a request.
- Offer whether verify permission and access in `RestfulActions` via
    `verify_permission` method. Return `true` to verify them.

```ruby
module MyStrategy
  extend ActiveSupport::Concern

  included do
    # Register verify_auth hook if you want to authenticate request.
    before_action :verify_auth
  end

  def access_token
    # Fetch some `attributes` from DB or auth server API using request.
    # Then returns an AccessToken with caching.
    @access_token ||= Garage::Strategy::AccessToken.new(attributes)
  end

  # Whether verify permission and access in `RestfulActions`.
  def verify_permission?
    true
  end
end
```

## Distributed tracing
In case you use auth-server strategy, you can setup distributed tracing for the service communication between garage application and auth server.
Currently, we support following tracers:

- `aws-xray` using [aws-xray](https://github.com/taiki45/aws-xray) gem.
  - Bundle `aws-xray` gem in your application.
  - Configure `service` option for a logical service name of the auth server.

```ruby
# e.g. aws-xray tracer
require 'aws/xray/hooks/net_http'
Garage::Tracer::AwsXrayTracer.service = 'your-auth-server-name'
Garage.configuration.tracer = Garage::Tracer::AwsXrayTracer
```

## Development

See [DEVELOPMENT.md](DEVELOPMENT.md).

## Authors

* Tatsuhiko Miyagawa
* Taiki Ono
* Yusuke Mito
* Ryo Nakamura

## Inspired By

* [roar](https://github.com/apotonick/roar)
* [doorkeeper](https://github.com/doorkeeper-gem/doorkeeper)
