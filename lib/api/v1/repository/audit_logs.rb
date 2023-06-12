# frozen_string_literal: true

module Api
  module V1
    module Repository
      class AuditLogs
        include Api::V1::Helper::DatabaseConnection

        def initialize(conn)
          @conn = conn
          @conn_audit_logs = @conn[:audit_logs]
        end

        #
        # get all audit_logs for a given year
        #
        # @param [Integer] year the year to get the audit_logs for
        #
        # @return [Array<Hash>] list of audit_logs
        #
        def for_year(year)
          from = Time.new(year, 1, 1)
          to = Time.new(year + 1, 1, 1)
          to_minus_a_second = to - 1

          @conn_audit_logs.where(created_at: from..to_minus_a_second).all
        end

        #
        # get all audit_logs for a given month in a given year
        #
        # @param [Integer] year the year to get the audit_logs for
        # @param [Integer] month the month to get the audit_logs for
        #
        # @return [Array<Hash>] list of audit_logs
        #
        def for_month(year, month)
          from = Time.new(year, month, 1)
          to = Time.new(year, month + 1, 1)
          to_minus_a_second = to - 1

          @conn_audit_logs.where(created_at: from..to_minus_a_second).all
        end

        #
        # get all audit_logs for a given day in a given month in a given year
        #
        # @param [Integer] year the year to get the audit_logs for
        # @param [Integer] month the month to get the audit_logs for
        # @param [Integer] day the day to get the audit_logs for
        #
        # @return [Array<Hash>] list of audit_logs
        #
        def for_day(year, month, day)
          from = Time.new(year, month, day)
          to = Time.new(year, month, day + 1)
          to_minus_a_second = to - 1
          @conn_audit_logs.where(created_at: from..to_minus_a_second).all
        end
      end
    end
  end
end
