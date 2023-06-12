# frozen_string_literal: true

module Api
  module V1
    module Locking
      class Locker
        include Api::V1::Helper::Repository

        attr_reader :tenant_db_connector

        def initialize(conn, params)
          @conn = conn
          @conn_bookings = @conn[:bookings]
          @conn_lockings = @conn[:lockings]
          @lock_params = cast_params!(params)
          @action = @lock_params.action
          @amount_cents_saldo_user_counted = @lock_params.amount_cents_saldo_user_counted
          @context = @lock_params.context
          @realized = build_realized(@lock_params)
          raise unless @amount_cents_saldo_user_counted.positive?
        end

        #
        # locks bookings for a given day
        #
        # @return [Hash] representing the new locking
        #
        def lock!
          @conn.transaction do
            @conn.run('LOCK TABLE lockings IN ACCESS EXCLUSIVE MODE')
            @conn.run('LOCK TABLE bookings IN ACCESS EXCLUSIVE MODE')
            validate!

            prelast_locking = load_latest_realized || last_active_locking_missing
            prelast_locking_amount_cents_saldo_user_counted = prelast_locking[:amount_cents_saldo_user_counted] || 0
            saldo_cents_calculated = get_saldo_cents_calculated(prelast_locking,
                                                                prelast_locking_amount_cents_saldo_user_counted)
            bookings = all_bookings_from_range(prelast_locking[:realized], @realized)
            insert_locking!(saldo_cents_calculated: saldo_cents_calculated,
                            bookings: bookings.to_json,
                            context: @context.to_json)
          end
        end

        private

        def cast_params!(params)
          Api::V1::Locking::ParamsCaster.new(params)
        end

        def deposit_minus_withdraw(prelast_locking)
          deposit = get_bookings_saldo_in_range(prelast_locking[:realized], @realized, 'deposit')
          withdraw = get_bookings_saldo_in_range(prelast_locking[:realized], @realized, 'withdraw')
          deposit - withdraw
        end

        def get_saldo_cents_calculated(prelast_locking, prelast_locking_amount_cents_saldo_user_counted)
          prelast_locking_amount_cents_saldo_user_counted + deposit_minus_withdraw(prelast_locking)
        end

        def all_bookings_from_range(from_realized, until_realized, sort_by: :realized)
          bookings = get_bookings_in_range(from_realized, until_realized, 'deposit')
                     .concat(get_bookings_in_range(from_realized, until_realized, 'withdraw'))
          bookings.sort_by! { |booking| booking[sort_by] }
        end

        def load_latest_realized
          query_lockings(@conn).last_active_realized(before_date_or_time: @realized)
        end

        def insert_locking!(saldo_cents_calculated:, bookings:, context: {})
          @conn_lockings.insert(saldo_cents_calculated: saldo_cents_calculated,
                                amount_cents_saldo_user_counted: @amount_cents_saldo_user_counted,
                                realized: @realized,
                                bookings_json: bookings,
                                context: context.to_json)
        end

        def get_bookings_in_range(from_realized, until_realized, action = 'deposit')
          raise ArgumentError unless %w[deposit withdraw].any?(action)

          @conn_bookings.where(action: action)
                        .where { realized > from_realized }
                        .where { realized <= until_realized }
                        .all
        end

        # TODO: factor this out or find duplicate usage then extract or reuse
        def get_bookings_saldo_in_range(earlies_date, until_date, action = 'deposit')
          raise ArgumentError unless %w[deposit withdraw].any?(action)

          @conn_bookings.where(action: action)
                        .where { realized > earlies_date }
                        .where { realized <= until_date }
                        .select(Sequel.lit('sum(cast(amount_cents as int)) as saldo '))
                        .first[:saldo] || 0
        end

        def last_active_locking_missing
          { realized: DB::EARLIEST_BOOKING }
        end

        def build_realized(lock_params)
          Time.new(lock_params.year, lock_params.month, lock_params.day)
        end

        def validate!
          validate_action!
          locking_last_realized = query_lockings(@conn).latest_active
          return if @realized > locking_last_realized[:realized]

          validate_realized!(locking_last_realized)
          raise Api::V1::Locking::LockingError.new(locking_last_realized),
                'There is already a newer lock in place!'
        end

        def validate_realized!(locking_last_realized)
          return unless @realized == locking_last_realized[:realized]

          raise Api::V1::Locking::LockingError.new(locking_last_realized),
                'There is already a lock in place for that exact day!'
        end

        def validate_action!
          return true if @action == 'lock'

          raise Api::V1::Locking::LockingError,
                "Action needs to be 'lock'!"
        end
      end
    end
  end
end
