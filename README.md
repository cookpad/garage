# Garage
Rails engine to add RESTful hypermedia API to your application.

## Usage

In `Gemfile`:

```ruby
gem 'garage', github: 'cookpad/garage'
```

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

## Configuration
```ruby
Garage.configuration.rescue_error # Set false if you want to rescue errors by yourself (default: true)
```
## Authors 

* Tatsuhiko Miyagawa
* Taiki Ono
* Yusuke Mito
* Ryo Nakamura

## Inspired By

* [roar](https://github.com/apotonick/roar)
* [doorkeeper](https://github.com/doorkeeper-gem/doorkeeper)

