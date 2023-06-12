# frozen_string_literal: true

module Api
  module V1
    module AuditLoggable
      #
      # Writes an AuditLog entry in a transaction
      #
      # @param [String] table_name telling what table was referenced at the time
      # @param [Object] before_state anything you'd want to have logged as JSONB as previous state
      # @yieldreturn [Object] pass an Array as an abstraction of action steps to be taken, see example
      #
      # @example Result state is an object
      #  create_audit_log!(conn, :lockings, @last_active_locking) do
      #    [query_find_by_id(query_find_last_active_id).update(active: false),
      #     query_find_by_id_first(@last_active_locking[:id])]
      #  end
      #
      # @example Result state is two objects
      #  create_audit_log!(conn, :lockings, @last_active_locking) do
      #    [query_find_by_id(query_find_last_active_id).update(active: false),
      #     { object_1: query_find_by_id_first(some_id),
      #       object_2: query_find_by_id_first(another_id) }]
      #  end
      #
      # @return [Object] describing the result_state of what was logged
      #
      def create_audit_log!(conn, table_name = 'system', before_state = {})
        before_state = Marshal.load(Marshal.dump(before_state)) unless before_state.empty?
        *_steps, result_state = yield

        conn.transaction do
          conn[:audit_logs].insert(table_referenced: table_name.to_s,
                                   environment_snapshot: before_state.to_json,
                                   log_entry: result_state.to_json)
        end
        result_state
      end
    end
  end
end
