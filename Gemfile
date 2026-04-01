# frozen_string_literal: true

source 'https://rubygems.org'

gem 'bigdecimal', '~> 4.1'
gem 'logger', '~> 1.7'
gem 'puma', '~> 7.2'
gem 'rack-unreloader', '~> 2.0'
gem 'rackup', '~> 2.3.1'
gem 'rake', '~> 13.3'
gem 'roda', '~> 3.102'

# postgres as adapter
gem 'sequel', '~> 5.103'
gem 'sequel_pg', '~> 1.19'

group :development do
  gem 'rubocop', '~> 1.86', require: false
  gem 'rubocop-minitest', '~> 0.39.1', require: false
  gem 'rubocop-performance', '~> 1.26', require: false
  gem 'rubocop-rake', '~> 0.7.1', require: false
  gem 'rubocop-sequel', '~> 0.4.0', require: false
  gem 'solargraph', require: false
end

group :development, :test do
  gem 'minitest', '~> 6.0'
  gem 'minitest-hooks', '~> 1.5'
  gem 'pry', '~> 0.16.0'
  gem 'rack-test', '~> 2.2'
end
