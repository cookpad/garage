# Garage
Rails framework to add RESTful hypermedia API to your application.

## What Is It?

Garage provides a simple, Hypermedia friendly RESTful API to your Rails application using its native RESTful routes. Garage provides a descriptive way to serve your ActiveRecord models, as well as plain old Ruby objects as JSON-based resources.

Garage supports OAuth 2 authorizations via Doorkeeper (more extensions to come), and provides resource-based access controls.

## Quickstart

In `Gemfile`:

```ruby
gem 'garage', github: 'cookpad/garage'
gem 'responders', '~> 2.0' # If you use Rails4.2+
```

In your Rails model class:

```ruby
class Employee < ActiveRecord::Base
  include Garage::Representer

  belongs_to :division
  property :id
  property :title
  property :first_name
  property :last_name

  property :division, selectable: true

  link(:division) { division_path(division) }

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

Doorkeeper.configure do
  # regular doorkeeper configurations go here

  default_scopes :public
  optional_scopes *Garage::TokenScope.optional_scopes
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

