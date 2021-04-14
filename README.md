# Loaders for graphql-batch

This is a personal collection of [graphql-batch](https://github.com/Shopify/graphql-batch) loaders that I have either authored or modified to my requirements, they are provided as-is and might help someone looking for a specific niche loader.

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
