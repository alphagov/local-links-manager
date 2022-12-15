source "https://rubygems.org"

gem "rails", "7.0.4"

gem "addressable"
gem "dalli"
gem "gds-api-adapters"
gem "gds-sso"
gem "google-api-client"
gem "googleauth"
gem "govuk_admin_template"
gem "govuk_app_config"
gem "gretel"
gem "jbuilder"
gem "mail", "~> 2.8.0"  # TODO: remove once https://github.com/mikel/mail/issues/1489 is fixed.
gem "mlanett-redis-lock"
gem "pg"
gem "plek"
gem "redis"
gem "rubocop-govuk"
gem "sassc-rails"
gem "sprockets-rails"
gem "uglifier"
gem "whenever", require: false

group :development do
  gem "better_errors"
  gem "binding_of_caller"
  gem "capistrano-rails"
  gem "web-console" # Access an IRB console by using <%= console %> in views
end

group :development, :test do
  gem "factory_bot_rails"
  gem "pry-rails"
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
