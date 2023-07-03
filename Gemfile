# frozen_string_literal: true

source 'https://rubygems.org'

gem 'alba', '~> 2.3'
gem 'oj', '~> 3.15'
gem 'puma', '~> 6.3'
gem 'rack-unreloader', '~> 2.0'
gem 'rackup', '~> 2.1.0'
gem 'rake', '~> 13.0'
gem 'roda', '~> 3.69'

# postgres as adapter
gem 'sequel', '~> 5.69'
gem 'sequel_pg', '~> 1.17'

group :development do
  gem 'rubocop', '~> 1.54', require: false
  gem 'rubocop-minitest', '~> 0.31.0', require: false
  gem 'rubocop-performance', '~> 1.18', require: false
  gem 'rubocop-rake', '~> 0.6.0', require: false
  gem 'rubocop-sequel', '~> 0.3.4', require: false
  gem 'solargraph', require: false
end

group :development, :test do
  gem 'minitest', '~> 5.18'
  gem 'minitest-hooks', '~> 1.5'
  gem 'pry', '~> 0.14.1'
  gem 'rack-test', '~> 2.0'
end
