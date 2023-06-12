# frozen_string_literal: true

module Api
  module V1
    module Repository
      class DbPreparator
        def initialize(tenant_account_id)
          @tenant_account_id = tenant_account_id
        end

        def reset!
          DB::DATABASE_SHARED_CONN.transaction do
            DB::DATABASE_SHARED_CONN[:tenants].where(tenant_db_id: "kaching_tenant_#{@tenant_account_id}").delete
            @tenant_db_connector = Db::SequelTenantDbConnector.new(tenant_id: @tenant_account_id, auto_init: true)
            @tenant_db_connector.connect_close(&:tables).each do |table|
              @tenant_db_connector.connect_close { |conn| conn.drop_table(table) }
            end
            @tenant_db_connector.migrate!
            @tenant_db_connector
          end
        end
      end
    end
  end
end
