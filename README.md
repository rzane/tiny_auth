# TinyAuth [![Build Status](https://travis-ci.org/rzane/tiny_auth.svg?branch=master)](https://travis-ci.org/rzane/tiny_auth) [![Coverage Status](https://coveralls.io/repos/github/rzane/tiny_auth/badge.svg?branch=master)](https://coveralls.io/github/rzane/tiny_auth?branch=master)

A utility for minimal user authentication.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tiny_auth'
```

And then execute:

    $ bundle

## Usage

### `TinyAuth::Model`

First, create a table to store your users:

```ruby
create_table :users do |t|
  t.string :email, null: false
  t.string :password_digest, null: false
  t.integer :token_version, null: false, default: 0
  t.index :email, unique: true
  t.index [:id, :token_version], unique: true
end
```

Your model should look like this:

```ruby
class User < ApplicationRecord
  include TinyAuth::Model
end
```

#### `#generate_token(purpose: :access, expires_in: 24.hours)`

Generate a token. The token is generated from the user's `id` and their `token_version`.

If the `token_version` changes, all previously issued tokens will be revoked. Anytime the
user's password changes, this will happen automatically.

```ruby
irb> user.generate_token
"eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJ..."

irb> user.generate_token(purpose: :reset, expires_in: 1.hour)
"eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJ..."
```

#### `#invalidate_tokens`

Increments the `#token_version`, but does not apply the change to the database.

#### `#invalidate_tokens!`

Increments the `#token_version` and applies the change to the database.

#### `.find_by_email(email)`

Find a user by their email address. The query will disregard casing.

```ruby
irb> User.find_by_email("user@example.com")
#<User id: 1, email: "user@example.com">
```

#### `.find_by_credentials(email, password)`

Find a user by their email, then check that the password matches.

If the email doesn't exist, `nil` will be returned. If the password doesn't match, `nil` will be returned.

```ruby
irb> User.find_by_credentials("user@example.com", "testing123")
#<User id: 1, email: "user@example.com">

irb> User.find_by_credentials("user@example.com", "")
nil

irb> User.find_by_credentials("", "")
nil
```

#### `.find_by_token(token, purpose: :access)`

Find a user by their token. If the user can't be found, `nil` will be returned.

```ruby
irb> User.find_by_token(token)
#<User id: 1, email: "user@example.com">

irb> User.find_by_token(reset_token, purpose: :reset)
#<User id: 1, email: "user@example.com">

irb> User.find_by_token("")
nil
```

### `TinyAuth::Controller`

```ruby
class ApplicationController < ActionController::Base
  include TinyAuth::Controller.new(model: User)
end
```

The example above would generate the following methods based on the model's name:

#### `#authenticate_user`

This method should be called in a `before_action`. If an `Authorization` header is found, it will attempt to locate a user.

#### `#current_user`

An accessor that can be used to obtain access to the authenticated user after calling `authenticate_user`.

#### `#user_signed_in?`

A convenience method to determine if a user is signed in.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rzane/tiny_auth. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the TinyAuth project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/rzane/tiny_auth/blob/master/CODE_OF_CONDUCT.md).
