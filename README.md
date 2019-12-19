# TinyAuth [![Build Status](https://travis-ci.org/rzane/tiny_auth.svg?branch=master)](https://travis-ci.org/rzane/tiny_auth)

A utility for minimal user authentication.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tiny_auth'
```

And then execute:

    $ bundle

## Usage

First, create a table to store your users:

```ruby
create_table :users do |t|
  t.string :email, null: false
  t.string :password_digest, null: false
  t.string :reset_token_digest
  t.datetime :reset_token_expires_at
  t.index :email, unique: true
  t.index :reset_token, unique: true
end
```

Your model should look like this:

```ruby
class User < ApplicationRecord
  include TinyAuth::Model
  has_secure_password
end
```

Now, you're ready to authenticate!

```ruby
user = User.find_by_email("user@example.com")
user = User.find_by_credentials("user@example.com", "password")

token = user.generate_token
user = User.find_by_token(token)

reset_token = user.generate_reset_token
user = User.exchange_reset_token(reset_token)
```

Oh, and you can add authentication to your controllers:

```ruby
class ApplicationController < ActionController::Base
  extend TinyAuth::Controller

  authenticates model: User

  def index
    if user_signed_in?
      render json: {id: current_user.id}
    else
      head :unauthorized
    end
  end
end
```

## Development

After checking out the repo, run `bundle install` to install dependencies.

Then, run `bundle exec rspec` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rzane/tiny_auth. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the TinyAuth project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/rzane/tiny_auth/blob/master/CODE_OF_CONDUCT.md).
