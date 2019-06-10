ruby File.read('.ruby-version').strip
source 'https://rubygems.org'

if ENV['API_DEV']
  gem 'gds-api-adapters', path: '../gds-api-adapters'
else
  gem 'gds-api-adapters', '~> 59.4.0'
end

gem 'addressable', '~> 2.6.0'
gem 'dalli'
gem 'google-api-client', '~> 0.30.2'
gem 'googleauth', '~> 0.8.1'
gem 'govuk_app_config', '~> 1.18.1'
gem 'govuk_admin_template', '~> 6.7'
gem 'govuk-lint'
gem 'gds-sso', '~> 14.0'
gem 'gretel', '3.0.9'
gem 'jbuilder', '~> 2.9'
gem 'mlanett-redis-lock', '0.2.7'
gem 'plek', '~> 3.0'
gem 'pg'
gem 'rails', '~> 5.2.3'
gem 'redis-namespace', '1.6.0'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'whenever', require: false

group :development do
  gem 'better_errors', '~> 2.5.1'
  gem 'binding_of_caller', '~> 0.8.0'
  gem 'capistrano-rails'
  gem 'web-console', '~> 3.7' # Access an IRB console by using <%= console %> in views
end

group :development, :test do
  gem 'factory_bot_rails', '~> 5'
  gem 'pry-rails'
  gem 'rspec-rails', '~> 3.8'
  gem 'shoulda-matchers', '~> 4.0'
  gem 'simplecov', '~> 0.16.1', require: false
  gem 'simplecov-rcov', '0.2.3', require: false
end

group :test do
  gem 'govuk_test', '~> 0.4.3'
  gem 'capybara', '~> 3.22'
  gem 'timecop'
  gem 'webmock', '~> 3.6.0'
end

group :doc do
  gem 'sdoc', '~> 1.0.0'
end
