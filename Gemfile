# frozen_string_literal: true

source 'https://rubygems.org'

gem 'alba', '~> 3.3'
gem 'bigdecimal', '~> 3.1'
gem 'oj', '~> 3.16'
gem 'puma', '~> 6.5'
gem 'rack-unreloader', '~> 2.0'
gem 'rackup', '~> 2.2.1'
gem 'rake', '~> 13.2'
gem 'roda', '~> 3.86'

# postgres as adapter
gem 'sequel', '~> 5.86'
gem 'sequel_pg', '~> 1.17'

group :development do
  gem 'rubocop', '~> 1.68', require: false
  gem 'rubocop-minitest', '~> 0.36.0', require: false
  gem 'rubocop-performance', '~> 1.23', require: false
  gem 'rubocop-rake', '~> 0.6.0', require: false
  gem 'rubocop-sequel', '~> 0.3.7', require: false
  gem 'solargraph', require: false
end

group :development, :test do
  gem 'minitest', '~> 5.25'
  gem 'minitest-hooks', '~> 1.5'
  gem 'pry', '~> 0.15.0'
  gem 'rack-test', '~> 2.0'
end
