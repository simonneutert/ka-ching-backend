# frozen_string_literal: true

module Db
  class SequelTenantDbConnector
    attr_reader :tenant_id,
                :auto_init

    attr_accessor :for_update

    def initialize(tenant_id:, auto_init: false, for_update: false)
      raise ArgumentError, 'tenant_id needs to be a String' unless tenant_id.is_a?(String)
      raise ArgumentError, 'tenant_id needs to be present' if tenant_id.empty?

      @tenant_id = tenant_id
      @auto_init = auto_init
      @for_update = for_update
    end

    def find_or_create!
      connect_close(&:tables)
    end

    def database_name_shared
      DB::DATABASE_NAME_SHARED.to_s
    end

    def database_name_tenant
      "#{DB::DATABASE_TENANT_DATABASE_NAMESPACE}#{@tenant_id}"
    end

    def connect_close(&)
      db(&)
    rescue Sequel::DatabaseConnectionError => e
      raise e unless e.message.include?('does not exist')
      raise e unless @auto_init

      create_and_migrate!
      db(&)
    end

    def migrate!
      db = DB.db_connection(database_name_tenant)
      db.extension(:constraint_validations, :pg_json)
      db.create_constraint_validations_table
      Sequel.extension(:migration, :core_extensions)
      Sequel::Migrator.apply(db, 'db/migrations', nil)
      update_shared!(database_name_tenant)
      db.disconnect
    end

    private

    def db(&)
      DB.db_connection(database_name_tenant, &)
    end

    def create!
      DB.db_connection(DB::DATABASE_USER) { |db| db.execute "CREATE DATABASE #{database_name_tenant}" }
    end

    def create_and_migrate!
      create! && migrate!
    end

    def update_shared!(database_name_tenant)
      DB::DATABASE_SHARED_CONN[:tenants].insert(
        id: SecureRandom.uuid,
        tenant_db_id: database_name_tenant,
        active: true,
        current_state: 'created'
      )
    end
  end
end
