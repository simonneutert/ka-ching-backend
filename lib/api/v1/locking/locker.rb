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
          @realized_at = build_realized_at(@lock_params)
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

            prelast_locking = load_latest_realized_at || last_active_locking_missing
            prelast_locking_amount_cents_saldo_user_counted = prelast_locking[:amount_cents_saldo_user_counted] || 0
            saldo_cents_calculated = get_saldo_cents_calculated(prelast_locking,
                                                                prelast_locking_amount_cents_saldo_user_counted)

            bookings = all_bookings_from_range(prelast_locking[:realized_at], @realized_at)
            insert_locking!(saldo_cents_calculated: saldo_cents_calculated,
                            bookings: bookings.to_json,
                            context: @context.to_json)
          end
        end

        private

        def future_saldo
          active_bookings = Api::V1::Repository::Bookings.new(@conn).active(@realized_at)
          active_bookings_grouped = active_bookings.group_by { |booking| booking[:action] }
          future_deposit_saldo(active_bookings_grouped) - future_withdraw_saldo(active_bookings_grouped)
        end

        def future_deposit_saldo(active_bookings_grouped)
          return 0 unless active_bookings_grouped['deposit']

          active_bookings_grouped['deposit'].sum { |booking| booking[:amount_cents] }
        end

        def future_withdraw_saldo(active_bookings_grouped)
          return 0 unless active_bookings_grouped['withdraw']

          active_bookings_grouped['withdraw'].sum { |booking| booking[:amount_cents] }
        end

        def cast_params!(params)
          Api::V1::Locking::ParamsCaster.new(params)
        end

        def deposit_minus_withdraw(prelast_locking)
          deposit = get_bookings_saldo_in_range(prelast_locking[:realized_at], @realized_at, 'deposit')
          withdraw = get_bookings_saldo_in_range(prelast_locking[:realized_at], @realized_at, 'withdraw')
          deposit - withdraw
        end

        def get_saldo_cents_calculated(prelast_locking, prelast_locking_amount_cents_saldo_user_counted)
          prelast_locking_amount_cents_saldo_user_counted + deposit_minus_withdraw(prelast_locking)
        end

        def all_bookings_from_range(from_realized_at, until_realized_at, sort_by: :realized_at)
          bookings = get_bookings_in_range(from_realized_at, until_realized_at, 'deposit')
                     .concat(get_bookings_in_range(from_realized_at, until_realized_at, 'withdraw'))
          bookings.sort_by! { |booking| booking[sort_by] }
        end

        def load_latest_realized_at
          query_lockings(@conn).last_active_realized_at(before_date_or_time: @realized_at)
        end

        def insert_locking!(saldo_cents_calculated:, bookings:, context: {})
          @conn_lockings.insert(saldo_cents_calculated: saldo_cents_calculated,
                                amount_cents_saldo_user_counted: @amount_cents_saldo_user_counted,
                                realized_at: @realized_at,
                                bookings_json: bookings,
                                context: context.to_json)
        end

        def get_bookings_in_range(from_realized_at, until_realized_at, action = 'deposit')
          raise ArgumentError unless %w[deposit withdraw].any?(action)

          @conn_bookings.where(action: action)
                        .where { realized_at > from_realized_at }
                        .where { realized_at <= until_realized_at }
                        .all
        end

        # TODO: factor this out or find duplicate usage then extract or reuse
        def get_bookings_saldo_in_range(earlies_date, until_date, action = 'deposit')
          raise ArgumentError unless %w[deposit withdraw].any?(action)

          @conn_bookings.where(action: action)
                        .where { realized_at > earlies_date }
                        .where { realized_at <= until_date }
                        .select(Sequel.lit('sum(cast(amount_cents as int)) as saldo '))
                        .first[:saldo] || 0
        end

        def last_active_locking_missing
          { realized_at: DB::EARLIEST_BOOKING }
        end

        def build_realized_at(lock_params)
          Time.new(lock_params.year, lock_params.month, lock_params.day)
        end

        def validate!
          validate_action!
          validate_future_saldo!
          locking_last_realized_at = query_lockings(@conn).latest_active
          return if @realized_at > locking_last_realized_at[:realized_at]

          validate_realized!(locking_last_realized_at)
          raise Api::V1::Locking::LockingError.new(locking_last_realized_at),
                'There is already a newer lock in place!'
        end

        def validate_future_saldo!
          return unless (@amount_cents_saldo_user_counted + future_saldo).negative?

          raise Api::V1::Locking::LockingError.new(@amount_cents_saldo_user_counted + future_saldo),
                'Saldo would be negative after locking'
        end

        def validate_realized!(locking_last_realized_at)
          return unless @realized_at == locking_last_realized_at[:realized_at]

          raise Api::V1::Locking::LockingError.new(locking_last_realized_at),
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
