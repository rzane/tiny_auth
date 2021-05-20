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

#### `.find_by_email(email)`

Find a user by their email address. The query will disregard casing.

```ruby
irb> User.find_by_email("user@example.com")

```

#### `.find_by_credentials(email, password)`

Find a user by their email, then check that the password matches.

```ruby
# Find a user by their email address
user = User.find_by_email("user@example.com")

# Find a user by their credentials
user = User.find_by_credentials("user@example.com", "password")

# Generate an access token that will expire
token = user.generate_token

# Find a user by their token
user = User.find_by_token(token)

# Generate a reset token
reset_token = user.generate_token(purpose: :reset, expires_in: 1.hour)

# Find a user by their reset token
user = User.find_by_reset_token(reset_token, purpose: :reset)
```

Oh, and you can add authentication to your controllers:

```ruby
class ApplicationController < ActionController::Base
  include TinyAuth::Controller.new(model: User)

  before_action :authenticate_user

  def index
    if user_signed_in?
      render json: {id: current_user.id}
    else
      head :unauthorized
    end
  end
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rzane/tiny_auth. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the TinyAuth project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/rzane/tiny_auth/blob/master/CODE_OF_CONDUCT.md).
