# frozen_string_literal: true

source 'https://rubygems.org'

gem 'bigdecimal', '~> 3.2'
gem 'puma', '~> 6.6'
gem 'rack-unreloader', '~> 2.0'
gem 'rackup', '~> 2.2.1'
gem 'rake', '~> 13.3'
gem 'roda', '~> 3.92'

# postgres as adapter
gem 'sequel', '~> 5.93'
gem 'sequel_pg', '~> 1.17'

group :development do
  gem 'rubocop', '~> 1.75', require: false
  gem 'rubocop-minitest', '~> 0.38.1', require: false
  gem 'rubocop-performance', '~> 1.25', require: false
  gem 'rubocop-rake', '~> 0.7.1', require: false
  gem 'rubocop-sequel', '~> 0.4.0', require: false
  gem 'solargraph', require: false
end

group :development, :test do
  gem 'minitest', '~> 5.25'
  gem 'minitest-hooks', '~> 1.5'
  gem 'pry', '~> 0.15.2'
  gem 'rack-test', '~> 2.2'
end
