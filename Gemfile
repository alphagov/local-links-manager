source "https://rubygems.org"

ruby "~> 3.3.1"

gem "rails", "8.1.2"

gem "addressable"
gem "aws-sdk-s3"
gem "bootsnap", require: false
gem "dalli"
gem "dartsass-rails"
gem "gds-api-adapters"
gem "gds-sso"
gem "google-api-client"
gem "googleauth"
gem "govuk_app_config", "9.22.0"
gem "govuk_publishing_components"
gem "gretel"
gem "jbuilder"
gem "mlanett-redis-lock"
gem "pg"
gem "plek"
gem "redis"
gem "rubocop-govuk"
gem "sprockets-rails"
gem "whenever", require: false

group :development do
  gem "better_errors"
  gem "capistrano-rails"
  gem "web-console" # Access an IRB console by using <%= console %> in views
end

group :development, :test do
  gem "erb_lint", require: false
  gem "factory_bot_rails"
  gem "pry-byebug"
  gem "rspec-rails"
  gem "shoulda-matchers"
  gem "simplecov", require: false
end

group :test do
  gem "capybara"
  gem "govuk_test"
  gem "timecop"
  gem "webmock"
end
