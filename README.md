# NOTE: This project is no longer maintened.

# Obscenity [![Build Status](https://secure.travis-ci.org/tjackiw/obscenity.png)](http://travis-ci.org/tjackiw/obscenity)

Obscenity is a profanity filter gem for Ruby/Rubinius, Rails (through ActiveModel), and Rack middleware.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'obscenity'
```

And then execute:

```ruby
bundle install
```

Or install it yourself as:

```ruby
gem install obscenity
```

## Compatibility

Obscenity is compatible with Ruby 1.9.X, Ruby 2.0.X, Rubinius 1.9, Rails 3.X, and Rack as a middleware. Starting with Rails 3, the profanity validation works with any ORM supported by ActiveModel, e.g: ActiveRecord, MongoMapper, Mongoid, etc. 

## Using Obscenity

The following methods are available to use with Obscenity:

### Configuration

`Obscenity.configure(&block)` allows you to set custom global configuration options. Available options are:

`config.blacklist` accepts the following values:

- An array with words
- A string representing a path to a yml file
- A Pathname object with a path to a yml file

`config.whitelist` accepts the following values:

- An array with words
- A string representing a path to a yml file
- A Pathname object with a path to a yml file

`config.replacement` accepts the following values:

- :default        : Uses the :garbled method
- :garbled        : Replaces profane words with $@!#%
- :stars          : Replaces profane words with '*' up to the word's length
- :vowels         : Replaces the vowels in the profane word with '*'
- :nonconsonants  : Replaces non consonants with '*'
- "custom string" : Replaces the profane word with the custom string

Example:

```ruby
Obscenity.configure do |config|
  config.blacklist   = "path/to/blacklist/file.yml"
  config.whitelist   = ["safe", "word"]
  config.replacement = :stars
end
```

### Basic Usage

`Obscenity.profane?(text)` analyses the content and returns `true` or `false` based on its profanity:

```ruby
Obscenity.profane?("simple text")
=> false

Obscenity.profane?("text with shit")
=> true
```

`Obscenity.sanitize(text)` sanities the content and returns a new sanitized content (if profane) or the original content (if not profane):

```ruby
Obscenity.sanitize("simple text")
=> "simple text"

Obscenity.sanitize("text with shit")
=> "text with $@!#%"
```
    
`Obscenity.replacement(style).sanitize(text)` allows you to pass the replacement method to be used when sanitizing the given content. Available replacement values are `:default`, `:garbled`, `:stars`, `:vowels`, and a custom string.

```ruby
Obscenity.replacement(:default).sanitize("text with shit")
=> "text with $@!#%"

Obscenity.replacement(:garbled).sanitize("text with shit")
=> "text with $@!#%"

Obscenity.replacement(:stars).sanitize("text with shit")
=> "text with ****"

Obscenity.replacement(:vowels).sanitize("text with shit")
=> "text with sh*t"

Obscenity.replacement(:nonconsonants).sanitize('Oh 5hit')
=> "Oh *h*t"

Obscenity.replacement("[censored]").sanitize("text with shit")
=> "text with [censored]"
```

`Obscenity.offensive(text)` returns an array of profane words in the given content:

```ruby
Obscenity.offensive("simple text")
=> []

Obscenity.offensive("text with shit and another biatch")
=> ["shit", "biatch"]
```

### ActiveModel

The ActiveModel component provides easy profanity validation for your models.

First, you need to explicitly require the ActiveModel component: 

```ruby
require 'obscenity/active_model'
```

Then you can use it in your models as such:

```ruby
# ActiveRecord example
class Post < ActiveRecord::Base
  
  validates :title, obscenity: true
  validates :body,  obscenity: { sanitize: true, replacement: "[censored]" }
end

# MongoMapper example
class Book
  include MongoMapper::Document

  key :title, String
  key :body,  String

  validates :title, obscenity: true
  validates :body,  obscenity: { sanitize: true, replacement: :vowels }
end

# Mongoid example
class Page
  include Mongoid::Document

  field :title, type: String
  field :body,  type: String

  validates :title, obscenity: true
  validates :body,  obscenity: { sanitize: true, replacement: :garbled }
end
```

The following usage is available:

`obscenity: true` : Does a profanity validation in the field using `.profane?` and returns `true/false`. If true, ActiveModel's Validation will return a default error message.

`obscenity: { message: 'Custom message' }` : Does a profanity validation in the field using `.profane?` and returns `true/false`. If true, ActiveModel's Validation will return your custom error message.

`obscenity: { sanitize: true }` : Silently sanitizes the field and replaces its content with the sanitized version. If the `:replacement` key is included, it will use that style when replacing the content.

### Rack middleware

You can use Obscenity as a Rack middleware to automatically reject requests that include profane parameter values or sanitize those values before they reach your Application.

First you need to explicitly require the Rack middleware:

```ruby
require 'obscenity/rack'
```

And to use the middleware, the basic syntax is:

```ruby
use Rack::Obscenity, {} # options Hash
```

You need to use the options below inside the options Hash (above)

#### Rejecting Requests:

Any of the following options can be used to reject a request.

`reject: true` : will reject a request if any parameter value contains profanity.

```ruby
use Rack::Obscenity, reject: true
```

`reject: { params: [] }` : will analyze the selected parameters and reject the request if their values contain profanity.

```ruby
use Rack::Obscenity, reject: { params: [:foo, :bar] }
```

`reject: { message: 'Custom message' }` : will reject a request and display the custom message if any parameter value contains profanity

```ruby
use Rack::Obscenity, reject: { message: "We don't allow profanity!" }
```

`reject: { path: 'path/to/file' }` :  will reject a request and render the custom file if any parameter value contains profanity

```ruby
use Rack::Obscenity, reject: { path: 'public/no_profanity.html' }
```

More usage example:

```ruby
# Rejects the request for all params and renders a file
use Rack::Obscenity, reject: { params: :all, path: 'public/no_profanity.html' }

# Rejects the request based on the selected params and renders a file
use Rack::Obscenity, reject: { params: [:foo, :bar], path: 'public/no_profanity.html' }

# Rejects the request based on the selected params and displays a message
use Rack::Obscenity, reject: { params: [:foo, :bar], message: "Profanity is not allowed!" }
```

#### Sanitizing Requests:

Any of the following options can be used to sanitize a request.

`sanitize: true` : will sanitize all parameter values if they contain profanity.

```ruby
use Rack::Obscenity, sanitize: true
```

`sanitize: { params: [] }` : will analyze the selected parameters and sanitize them if their values contain profanity.

```ruby
use Rack::Obscenity, sanitize: { params: [:foo, :bar] }
```

`sanitize: { replacement: (:default | :garbled | :stars | :vowels | 'custom') }` : will use this replacement method when sanitizing parameter values

```ruby
use Rack::Obscenity, sanitize: { replacement: :vowels }
```

More usage example:

```ruby
# Sanitizes all params and replaces their values using :stars
use Rack::Obscenity, sanitize: { params: :all, replacement: :stars }

# Sanitizes the given params and replaces their values using a custom word
use Rack::Obscenity, sanitize: { params: [:foo, :bar], replacement: "[censored]" }

# Sanitizes all params and replaces their values using :garbled
use Rack::Obscenity, sanitize: { replacement: :garbled }
```
### Test Helpers

Obscenity currently provides test helpers for RSpec only, but we have plans to add helpers to Shoulda as well.

#### RSpec Matcher

A `be_profane` matcher is available for RSpec. Its usage is very simple:

```ruby
user.username.should_not be_profane
```

## Contributing to obscenity
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history.

## Authors

* Thiago Jackiw: [@tjackiw](http://twitter.com/tjackiw)

## Copyright

Copyright (c) 2012 Thiago Jackiw. See LICENSE.txt for further details.

