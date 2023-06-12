# frozen_string_literal: true

require_relative '../db'

require 'minitest/autorun'
require 'minitest/hooks'
require 'minitest/hooks/test'

require 'rack/builder'
require 'rack/test'
require 'json'
require 'pry' unless ENV['RACK_ENV'] == 'production'

class ApiIntegrationHelperTest < Minitest::Test
  include Minitest::Hooks

  def app
    OUTER_APP
  end

  def header_content_type_json
    { 'CONTENT_TYPE' => 'application/json' }
  end

  #
  # around hook to create a tenant db and run migrations
  #
  def around
    drop_tables!
    set_extensions!
    create_constraint_validations_table!
    Sequel::Migrator.run(DB::DATABASE_TENANT_TEST_CONN, 'db/migrations', target: nil)
    super
  end

  private

  def drop_tables!
    DB::DATABASE_TENANT_TEST_CONN.tables.each do |t|
      DB::DATABASE_TENANT_TEST_CONN.drop_table t
    end
  end

  def set_extensions!
    DB::DATABASE_TENANT_TEST_CONN.extension(:constraint_validations, :pg_json)
  rescue StandardError
    nil
  end

  def create_constraint_validations_table!
    DB::DATABASE_TENANT_TEST_CONN.create_constraint_validations_table
  rescue StandardError
    # all good
  end
end

OUTER_APP = Rack::Builder.parse_file('config.ru')
