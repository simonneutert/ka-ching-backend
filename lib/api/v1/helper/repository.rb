# frozen_string_literal: true

module Api
  module V1
    module Helper
      module Repository
        include Api::V1::Helper::DatabaseConnection

        def db(tenant_db_connector, table)
          result = nil # to catch the result of the block
          tenant_db_connector.connect_close do |connection|
            connection.extension(:pagination)
            conn = connection[table.to_sym]
            conn = conn.for_update if tenant_db_connector.for_update
            result = yield(conn)
          end
          result
        end

        def query_lockings(conn)
          @query_lockings ||=
            Api::V1::Repository::Lockings.new(conn)
        end

        def query_audit_logs(conn)
          @query_audit_logs ||=
            Api::V1::Repository::AuditLogs.new(conn)
        end

        def query_bookings(conn)
          @query_bookings ||=
            Api::V1::Repository::Bookings.new(conn)
        end

        def query_saldos(conn)
          @query_saldos ||=
            Api::V1::Repository::Saldo.new(conn)
        end
      end
    end
  end
end
