ruby File.read(".ruby-version").strip
source "https://rubygems.org"

if ENV["API_DEV"]
  gem "gds-api-adapters", path: "../gds-api-adapters"
else
  gem "gds-api-adapters", "~> 63.6.0"
end

gem "addressable", "~> 2.7.0"
gem "dalli"
gem "gds-sso", "~> 14.3"
gem "google-api-client", "~> 0.39.3"
gem "googleauth", "~> 0.12.0"
gem "govuk_admin_template", "~> 6.7"
gem "govuk_app_config", "~> 2.1.2"
gem "gretel", "3.0.9"
gem "jbuilder", "~> 2.10"
gem "mlanett-redis-lock", "0.2.7"
gem "pg"
gem "plek", "~> 3.0"
gem "rails", "~> 6.0.2"
gem "redis-namespace", "1.7.0"
gem "rubocop-govuk"
gem "sass-rails", "~> 6.0"
gem "scss_lint-govuk"
gem "uglifier", ">= 1.3.0"
gem "whenever", require: false

group :development do
  gem "better_errors", "~> 2.7.0"
  gem "binding_of_caller", "~> 0.8.0"
  gem "capistrano-rails"
  gem "web-console", "~> 4.0" # Access an IRB console by using <%= console %> in views
end

group :development, :test do
  gem "factory_bot_rails", "~> 5"
  gem "pry-rails"
  gem "rspec-rails", "~> 4.0.0"
  gem "shoulda-matchers", "~> 4.3"
  gem "simplecov", "~> 0.18.5", require: false
  gem "simplecov-rcov", "0.2.3", require: false
end

group :test do
  gem "capybara", "~> 3.32"
  gem "govuk_test", "~> 1.0.3"
  gem "timecop"
  gem "webmock", "~> 3.8.3"
end

group :doc do
  gem "sdoc", "~> 1.1.0"
end
