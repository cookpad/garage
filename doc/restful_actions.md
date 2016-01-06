# Garage::RestfulActions

Garage::RestfulActions is a mix-in to add simple RESTful CRUD actions to your action controllers.

## Usage

```ruby
class PostsController < ApiController
  include Garage::RestfulActions
  
  def require_resources
    @resources = Post.all
  end
  
  def require_resource
    @resource = Post.find(params[:id])
  end
  
  def create_resource
    @resource = @resources.new(user_id: current_resource_owner.id)
    @resource.save!
    @resource
  end
  
  def update_resource
    @resource.update_attributes!(params.slice(...))
    @resource
  end
  
  def destroy_resource
    @resource.destroy
    @resource
  end
end
```

## resources and resource

RestfulActions assumes your controller has one resource class to manipulate. You're supposed to implement both `require_resources` and `require_resource` to return the collection for resource(s) and particular resource with identifier.

```
GET /posts (index)
  -> show @resources
POST /posts (create)
  -> show @resource = @resources.new 
GET /posts/:id (show)
  -> show @resource
PUT /posts/:id (update)
  -> update @resource
DELETE /posts/:id (destroy)
  -> delete @resource
```

### Access & Permission

RestfulActions automatically checks whether your access tokens have access to the requested operation on the resource (class), and whether the actual authorized user has the permission to perform task on.

Access is checked against the resource class, while permission is checked against the actual resource (usually database model) or MetaResource, in case of streams (`index` and `create` actions).

```
GET /posts (index)
  -> access Post, :read
  -> permission Post, :read
POST /posts (create)
  -> access Post, :write
  -> permission Post, :write
GET /posts/:id (show)
  -> access Post, :read
  -> permission @resource, :read
PUT /posts/:id (update)
  -> access Post, :write
  -> permission @resource, :write
DELETE /posts/:id (destroy)
  -> access Post, :write
  -> permission @resource, :write
```

In case of `@resources`, the default resource class is retrieved using `@resources.klass`, assuming the object is ActiveRecord::Relation that encapsulates the model class.

You can override this using `protect_resource_as` method in your controller:

```ruby
def require_resources
  @resources = Post.where(user_id: @user.id)
  protect_resource_as PrivatePost, user: @user
end
```

This declares that the access token should have scope(s) to access `PrivatePost` class, rather than `Post` class, and permissions will be checked against `{ user: @user }` in permission builder (see below).

You can also *add* extra access scope or permission in addition to `@resource(s)` in your controller.

```ruby
before_action require_recipe
def require_recipe
  @recipe = Recipe.find(params[:recipe_id])
  require_permission! @recipe, :read
end
```

This will ensure the requesting user has a read permission to the `@recipe` object. There's also `require_access!` and `require_access_and_permission!` to check access control as well.

### Defining Access Control

Access control can be declared in your Garage initializer file, typically `config/initializers/garage.rb`:

```ruby
Garage::TokenScope.configure do
  register :public, desc: "acessing publicly available data" do
    access :read, Recipe
    access :read, Post
  end
  
  register :write_recipe, desc: "writing recipe" do 
    access :write, Recipe
  end
end
```

This way, tokens that has `write_recipe` scope will have access to write resources that belong to Recipe class.

### Defining Permissions

Permissions on resources can be declared by implementing `build_permissions` method in your resource (or model class).

Start by adding Garage::Authorizable in your resource class:

```ruby
class Post
  include Garage::Authorizable
  
  def build_permissions(perms, other); end
  def self.build_permissions(perms, other, target); end
end
```

There are two `build_permissions`, instance method and class method. Both are called automatically by RestfulActions when necessary.

Instance method version is called when permissions against `@resource` are checked, for `show`, `update` or `destroy` actions.

Typically, an implementation will call `permits!` method on `perms` object to declare read or write permissions for the user specified in `other`. Both read and write permissions are declared as forbidden by default.

You can also call `deleted!` action to declare that the resource doesn't exist. It will be useful when your application handle deletes as soft deletes (no physical deletions from the table).

```ruby
  def build_permissions(perms, other)
    perms.deleted! if self.deleted?
    
    perms.permits! :write if owner_id == other.id
    perms.permits! :read
  end
```

Class method version is called when permissions against `@resources` are checked, for `create` and `index` actions.

```ruby
  def self.build_permissions(perms, other, target)
    if target[:user]
      perms.permits! :read, :write if target[:user].id == owner_id
    else
      perms.permits! :read, :write
    end
  end
```

`target` hash contains arguments passed to `protect_resource_as`, when defined.

    
  
