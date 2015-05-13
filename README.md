# Garage
[![Build Status](https://travis-ci.org/cookpad/garage.svg?branch=master)](https://travis-ci.org/cookpad/garage)

Rails framework to add RESTful hypermedia API to your application.

## What Is It?

Garage provides a simple, Hypermedia friendly RESTful API to your Rails application using its native RESTful routes. Garage provides a descriptive way to serve your ActiveRecord models, as well as plain old Ruby objects as JSON-based resources.

Garage supports OAuth 2 authorizations via Doorkeeper (more extensions to come), and provides resource-based access controls.

## Quickstart

In `Gemfile`:

```ruby
gem 'garage', github: 'cookpad/garage'
```

In your Rails model class:

```ruby
class Employee < ActiveRecord::Base
  include Garage::Representer

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

In your controller class:

```ruby
class EmployeesController < ApplicationController
  include Garage::RestfulActions

  def require_resources
    @resources = Employee.all
  end
end
```

## Advanced Configurations

In `config/initializer/garage.rb`:

```ruby
# Optional
Garage::TokenScope.configure do
  register :public, desc: "accessing publicly available data" do
    access :read, Recipe
  end

  register :read_post, desc: "reading blog post" do
    access :read, Post
  end
end

# If you to want use different authentication/authorization logic.
Garage.configuration.auth_filter = Garage::AuthFilter::Test
```

The following auth filters are available.

- `Garage::AuthFilter::NoAuthentication` - Does not authenticate request and
    does not verify permission and access on resource operation. For non-public,
    internal-use Garage application.
- `Garage::AuthFilter::Test` - Trust request thoroughly, and build access token
    from request headers. For testing or prototyping.
- `Garage::AuthFilter::Doorkeeper` - Authenticate request with doorkeeper gem.
    To use this filter, bundle [garage-doorkeeper gem](https://github.com/taiki45/garage-doorkeeper).
- `Garage::AuthFilter::AuthServer` - Delegate authentication to OAuth server.
    This auth filter has configurations. See detail at `lib/garage/auth_filter/auth_server.rb`.

## Customize Authentication/Authorization

Garage supports customizable Authentication/Authorization filter.
The AuthFilter has some conventions to follow.

- Offer OAuth access token via `access_token` method. With no access token case
    (does not authenticate request) `access_token` should return `nil`.
- Register `verify_auth` hook as before filter in `included` block if
    authenticate request. Or register custom authentication hook. The custom
    authentication hook should response unauthorized using
    `unauthorized_render_options` when fails to authenticate a request.
- Offer whether verify permission and access in `RestfulActions` via
    `verify_permission` method. Return `true` to verify them.

```ruby
module MyAuthFilter
  extend ActiveSupport::Concern

  included do
    # Register verify_auth hook if you want to authenticate request.
    before_action :verify_auth
  end

  def access_token
    # Fetch some `attributes` from DB or auth server API using request.
    # Then returns an AccessToken with caching.
    @access_token ||= Garage::AuthFilter::AccessToken.new(attributes)
  end

  # Whether verify permission and access in `RestfulActions`.
  def verify_permission?
    true
  end
end
```

## Authors

* Tatsuhiko Miyagawa
* Taiki Ono
* Yusuke Mito
* Ryo Nakamura

## Inspired By

* [roar](https://github.com/apotonick/roar)
* [doorkeeper](https://github.com/doorkeeper-gem/doorkeeper)
