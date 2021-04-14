# Loaders for graphql-batch

This is a personal collection of [graphql-batch](https://github.com/Shopify/graphql-batch) loaders that I have either authored or modified to my requirements, they are provided as-is and might help someone looking for a specific niche loader.

Loader | Purpose
--- | ---
[CountLoader](#countloader) | Batches counts on a model by values of a specific field.
[AssociationCountLoader](#associationcountloader) | Batches counts on a model through a defined association.
[AssociationFindByLoader](#associationfindbyloader) | Finds single records through an association on a record by a specific value on the associated table.

## [CountLoader](loaders/count_loader.rb)

Batches counts on a model by values of a specific field.

Additional information can be found [at this blog post](https://blog.jamesbrooks.net/graphql-batch-count-loader.html).

### Invocation

```ruby
CountLoader.for(model, field).load(value)
```

### Non-batched equivalent

```ruby
model.where(field => value).count
```

### Example

```ruby
class User < ApplicationRecord
  has_many :posts
end

class Post < ApplicationRecord
  belongs_to :user
end

class Types::UserType < Types::BaseObject
  field :post_count, Integer

  def post_count
    CountLoader.for(Post, :user_id).load(object.id)
  end
end
```

## [AssociationCountLoader](loaders/association_count_loader.rb)

Batches counts on a model through a defined association.

Additional information can be found [at this blog post](https://blog.jamesbrooks.net/graphql-batch-count-loader.html).

### Invocation

```ruby
AssociationCountLoader.for(model, association).load(record)
```

### Non-batched equivalent

```ruby
model.association.count
```

### Example

```ruby
class User < ApplicationRecord
  has_many :posts
end

class Post < ApplicationRecord
  belongs_to :user
end

class Types::UserType < Types::BaseObject
  field :post_count, Integer

  def post_count
    AssociationCountLoader.for(User, :posts).load(object)
  end
end
```

## [AssociationFindByLoader](loaders/association_find_by_loader.rb)

Finds single records through an association on a record by a specific value on the associated table.

This is very useful for edge types on collections to batch load join models based off of the current user.

### Invocation

```ruby
AssociationFindByLoader.for(record, association, field)
      .load(value)(record)
```

### Non-batched equivalent

```ruby
record.association.find_by(field: value)
```

### Example

This is a more in-depth example and not all ActiveRecord associations or GraphQL types are fully fleshed out. The following demonstrates a concrete use-case.

```ruby
class User < ApplicationRecord
  has_many :group_memberships
  has_many :groups, through: :group_memberships
end

class GroupMembership < ApplicationRecord
  belongs_to :user
  belongs_to :group

  enum :role, [ :member, :admin ]
end

class Group < ApplicationRecord
end

class Types::GroupType < Types::BaseObject
  edge_type_class Types::GroupMembershipEdge
end

class Types::GroupMembershipEdge < Types::BaseEdge
  field :role, Types::GroupMembershipEdgeEnum, null: false

  def role
    AssociationFindByLoader
      .for(current_user, :group_memberships, :group_id)
      .load(node.id)
      .then(&:role)
  end
end
```
