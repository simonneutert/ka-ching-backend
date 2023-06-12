# frozen_string_literal: true

require 'logger'
require 'sequel/core'
require 'pry' if ENV['RACK_ENV'] == 'development'

require_relative 'db'
Sequel.extension :migration

unless ENV['RACK_ENV'] == 'production'
  require 'minitest/test_task'
  Minitest::TestTask.create(:test) do |t|
    t.libs << 'test'
    t.libs << 'lib'
    t.warning = false
    t.test_globs = ['test/**/*_test.rb']
  end

  task default: :test
end

namespace :db do # rubocop:disable Metrics/BlockLength
  namespace :test do
    desc 'prepare tests'
    task :prepare do
      DB.db_connection(DB::DATABASE_NAME_SHARED) do |db|
        db.execute("CREATE DATABASE #{DB::DATABASE_TENANT_DATABASE_NAMESPACE}test")
      end
      db = DB.db_connection("#{DB::DATABASE_TENANT_DATABASE_NAMESPACE}test")
      db.extension(:constraint_validations, :pg_json)
      db.create_constraint_validations_table
      db.disconnect
    end
  end

  desc 'create tables'
  task :create do
    # TODO: make the root db configurable
    DB.db_connection('postgres') do |db|
      db.execute "CREATE DATABASE #{DB::DATABASE_NAME_BLANK}"
    end
    db = DB.db_connection(DB::DATABASE_NAME_BLANK)
    db.extension(:constraint_validations, :pg_json)
    db.create_constraint_validations_table
    db.disconnect
  end

  desc 'Run migrations'
  task :migrate, [:version] do |_t, args|
    version = args[:version].to_i if args[:version]
    db = DB.db_connection(DB::DATABASE_NAME_BLANK)
    db.extension(:constraint_validations, :pg_json)
    begin
      db.create_constraint_validations_table
    rescue StandardError
      # do nothing, it will be alright
    end
    Sequel::Migrator.run(db, 'db/migrations', target: version)
    db.disconnect
  end

  desc 'Run migrations'
  task :migrate_tenant_account, [:version, :tenant_account_id] do |_t, args|
    version = args[:version].to_i if args[:version]
    if args[:tenant_account_id] == 'all'
      DB::DATABASE_SHARED_CONN[:tenants].all.each do |tenant|
        db_name = tenant[:tenant_db_id]
        db = DB.db_connection(db_name)
        db.extension(:constraint_validations, :pg_json)
        begin
          db.create_constraint_validations_table
        rescue StandardError
          # do nothing, it will be alright
        end
        Sequel::Migrator.run(db, 'db/migrations', target: version)
        db.disconnect
      end
    else
      db_name = "#{DB::DATABASE_TENANT_DATABASE_NAMESPACE}#{args[:tenant_account_id]}"
      db = DB.db_connection(db_name)
      db.extension(:constraint_validations, :pg_json)
      begin
        db.create_constraint_validations_table
      rescue StandardError
        # do nothing, it will be alright
      end
      Sequel::Migrator.run(db, 'db/migrations', target: version)
      db.disconnect

    end
  end

  desc 'drop tables'
  task :drop do
    if ENV.fetch('RACK_ENV', 'development') == 'production'
      puts ''
      puts 'ARE YOU SURE?'
      puts 'I will be WAITING for 5 seconds, just to make sure you are sure.'
      puts ''
      sleep 5
    end
    DB::DATABASE_NAME_BLANK.tables.each do |t|
      DB::DATABASE_NAME_BLANK.drop_table(t)
    rescue StandardError => e
      puts "#{t} table could not be dropped #{e}"
    end
  end

  namespace :shared do
    desc 'init'
    task :init, [:version] do |_t, args|
      version = args[:version].to_i if args[:version]
      DB.db_connection(DB::DATABASE_USER) do |db|
        db.execute "CREATE DATABASE #{DB::DATABASE_NAME_SHARED}"
      end
      db = DB.db_connection(DB::DATABASE_NAME_SHARED)
      db.extension(:constraint_validations, :pg_json)
      begin
        db.create_constraint_validations_table
      rescue StandardError
        # do nothing
      end
      Sequel::Migrator.run(db, 'db/migrations_shared', target: version)
      db.disconnect
    end

    desc 'Run migrations'
    task :migrate, [:version] do |_t, args|
      version = args[:version].to_i if args[:version]
      db = DB.db_connection(DB::DATABASE_NAME_SHARED)
      db.extension(:constraint_validations, :pg_json)
      begin
        db.create_constraint_validations_table
      rescue StandardError
        # do nothing, it will be alright
      end
      Sequel::Migrator.run(db, 'db/migrations_shared', target: version)
      db.disconnect
    end
  end
end
