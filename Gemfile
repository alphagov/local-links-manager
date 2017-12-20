ruby File.read('.ruby-version').strip
source 'https://rubygems.org'

if ENV['API_DEV']
  gem 'gds-api-adapters', path: '../gds-api-adapters'
else
  gem 'gds-api-adapters', '~> 47.9.1'
end

gem 'addressable', '~> 2.5.1'
gem 'dalli'
gem 'faraday'
gem 'faraday_middleware'
gem 'google-api-client', '~> 0.17.0'
gem 'googleauth', '~> 0.5.3'
gem 'govuk_app_config', '~> 0.2.0'
gem 'govuk_admin_template', '~> 6.4'
gem 'govuk-lint', '1.2.1'
gem 'gds-sso', '~> 13.0'
gem 'gretel', '3.0.9'
gem 'jbuilder', '~> 2.0'
gem 'logstasher', '0.6.2'
gem 'mlanett-redis-lock', '0.2.7'
gem 'plek', '~> 2.0'
gem 'pg'
gem 'rails', '~> 5.0.0'
gem 'redis-namespace', '1.5.2'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'unicorn', '~> 5.3.1'
gem 'whenever', require: false

group :development do
  gem 'capistrano-rails'
  gem 'web-console', '~> 2.0' # Access an IRB console by using <%= console %> in views
end

group :development, :test do
  gem 'capybara', '~> 2.7'
  gem 'factory_girl_rails', '~> 4.7'
  gem 'pry-rails'
  gem 'rspec-rails', '~> 3.5'
  gem 'shoulda-matchers', '~> 3.1'
  gem 'simplecov', '~> 0.15.0', require: false
  gem 'simplecov-rcov', '0.2.3', require: false
end

group :test do
  gem 'timecop'
  gem 'webmock', '~> 3.1.1'
end

group :doc do
  gem 'sdoc', '~> 0.4.0'
end
