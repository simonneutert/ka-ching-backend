# frozen_string_literal: true

require 'logger'
require 'rack/unreloader'

dev = ENV['RACK_ENV'] == 'development'
load('./db.rb')

Unreloader = Rack::Unreloader.new(subclasses: %w[Roda Sequel::Model], reload: dev) { App }

Unreloader.require('./lib/db.rb')
Unreloader.require('./lib/api/v1/helper/**/*.rb')
# load the errors first
Unreloader.require('./lib/**/*_error.rb')
# load the stuff others inherit from
Unreloader.require('./lib/booking/booker.rb')
Unreloader.require('./lib/locking/locker*.rb')
# load everything else
Unreloader.require('./lib/**/*.rb')
Unreloader.require('./app.rb') { 'App' }

begin
  Sequel::Migrator.check_current(DATABASE_TENANT_BLANK_CONN, './db/migrations')
rescue StandardError
  nil
end

run(dev ? Unreloader : App)
