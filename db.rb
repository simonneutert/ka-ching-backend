# frozen_string_literal: true

require 'sequel'
require 'logger'

module DB
  EARLIEST_BOOKING = Time.new(1, 1, 1)
  LOGGER = Logger.new($stdout)
  LOGGER.level = Logger::WARN if ENV['RACK_ENV'] == 'production'

  DATABASE_USER = ENV.fetch('DATABASE_USER', 'postgres')
  DATABASE_PASSWORD = ENV.fetch('DATABASE_PASSWORD', 'postgres')
  DATABASE_URL = ENV.fetch('DATABASE_URL', 'localhost')
  DATABASE_PORT = ENV.fetch('DATABASE_PORT', '5432')

  DATABASE_TENANT_DATABASE_NAMESPACE = ENV.fetch('DATABASE_TENANT_DATABASE_NAMESPACE', 'kaching_tenant_')
  DATABASE_NAME_SHARED = ENV.fetch('DATABASE_NAME_SHARED', 'kaching_shared')
  DATABASE_NAME_BLANK = ENV.fetch('DATABASE_NAME_BLANK', "#{DATABASE_TENANT_DATABASE_NAMESPACE}blank")

  Sequel.extension :migration

  def self.db_connection(database, &block)
    Sequel.connect(
      "postgres://#{DATABASE_URL}:#{DATABASE_PORT}/#{database}?user=#{DATABASE_USER}&password=#{DATABASE_PASSWORD}",
      logger: DB::LOGGER,
      &block
    )
  end

  begin
    DATABASE_SHARED_CONN = db_connection(DATABASE_NAME_SHARED)
    DATABASE_SHARED_CONN.extension(:constraint_validations, :pg_json)
    DATABASE_SHARED_CONN.extension(:pagination)

    DATABASE_TENANT_BLANK_CONN = db_connection(DATABASE_NAME_BLANK)
    DATABASE_TENANT_BLANK_CONN.extension(:constraint_validations, :pg_json)
    DATABASE_TENANT_BLANK_CONN.extension(:pagination)

    DATABASE_TENANT_TEST_CONN = db_connection("#{DATABASE_TENANT_DATABASE_NAMESPACE}test")
    DATABASE_TENANT_TEST_CONN.extension(:constraint_validations, :pg_json)
    DATABASE_TENANT_TEST_CONN.extension(:pagination)
  rescue Sequel::DatabaseConnectionError => e
    puts e
    raise e unless e.message.include?('does not exist')
  rescue StandardError => e
    puts e
  end
end
