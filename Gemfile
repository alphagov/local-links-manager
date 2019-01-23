ruby File.read('.ruby-version').strip
source 'https://rubygems.org'

if ENV['API_DEV']
  gem 'gds-api-adapters', path: '../gds-api-adapters'
else
  gem 'gds-api-adapters', '~> 57.1.0'
end

gem 'addressable', '~> 2.5.1'
gem 'dalli'
gem 'google-api-client', '~> 0.28.0'
gem 'googleauth', '~> 0.6.7'
gem 'govuk_app_config', '~> 1.11.2'
gem 'govuk_admin_template', '~> 6.6'
gem 'govuk-lint'
gem 'gds-sso', '~> 14.0'
gem 'gretel', '3.0.9'
gem 'jbuilder', '~> 2.8'
gem 'mlanett-redis-lock', '0.2.7'
gem 'plek', '~> 2.1'
gem 'pg'
gem 'rails', '~> 5.2.2'
gem 'redis-namespace', '1.6.0'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'whenever', require: false

group :development do
  gem 'capistrano-rails'
  gem 'web-console', '~> 3.7' # Access an IRB console by using <%= console %> in views
end

group :development, :test do
  gem 'capybara', '~> 3.10'
  gem 'factory_bot_rails', '~> 4'
  gem 'pry-rails'
  gem 'rspec-rails', '~> 3.8'
  gem 'shoulda-matchers', '~> 3.1'
  gem 'simplecov', '~> 0.16.1', require: false
  gem 'simplecov-rcov', '0.2.3', require: false
end

group :test do
  gem 'timecop'
  gem 'webmock', '~> 3.5.1'
end

group :doc do
  gem 'sdoc', '~> 1.0.0'
end
