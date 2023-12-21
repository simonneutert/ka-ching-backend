# frozen_string_literal: true

require_relative '../audit_loggable'
module Api
  module V1
    module Locking
      class Deactivator
        include Api::V1::AuditLoggable
        include Api::V1::Helper::Repository

        attr_reader :tenant_db_connector

        def initialize(conn)
          @conn = conn
          @conn_lockings = @conn[:lockings]
          @conn_audit_logs = @conn[:audit_logs]
        end

        #
        # open last locking and deactivate it
        #
        # @return [Hash] representing the deactivated locking audit_log entry
        #
        def open_last_locking!
          @conn.transaction do
            @conn.run('LOCK TABLE lockings IN ACCESS EXCLUSIVE MODE')
            @conn.run('LOCK TABLE bookings IN ACCESS EXCLUSIVE MODE')
            @conn.run('LOCK TABLE audit_logs IN ACCESS EXCLUSIVE MODE')

            @last_active_locking = query_find_by_id_first(query_find_last_active_id)
            validate!

            create_audit_log!(@conn, :lockings, @last_active_locking) do
              [query_find_by_id(query_find_last_active_id).update(active: false),
               query_find_by_id_first(@last_active_locking[:id])]
            end
          end
        end

        private

        def query_find_by_id(id)
          @conn_lockings.where(id:)
        end

        def query_find_by_id_first(id)
          query_find_by_id(id).first
        end

        def query_find_last_active_id
          @conn_lockings.where(active: true)
                        .order(:realized_at)
                        .last[:id]
        end

        def validate!
          validate_no_newer_booking!
          last_reopened_locking = @conn_lockings.where(active: false).order(:realized_at).last

          return true if last_reopened_locking.nil?
          return unless last_reopened_locking[:realized_at] > @last_active_locking[:realized_at]

          raise Api::V1::Locking::DeactivatorError, message_remove_last_lock_only
        end

        def validate_no_newer_booking!
          return unless active_realized_at_present?

          raise Api::V1::Locking::DeactivatorError, message_remove_last_lock_only
        end

        def message_remove_last_lock_only
          'You can unlock the last lock only, now go wash your hands!'
        end

        def active_realized_at_present?
          query_bookings(@conn).active(
            @last_active_locking[:realized_at],
            order: :realized_at
          ).any?
        end
      end
    end
  end
end
