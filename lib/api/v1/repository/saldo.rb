# frozen_string_literal: true

module Api
  module V1
    module Repository
      class Saldo
        include Api::V1::Helper::DatabaseConnection

        def initialize(conn)
          @conn = conn[:bookings]
          @conn_locking = conn[:lockings]
        end

        #
        # get the current saldo
        #
        # @return [Integer] the current saldo
        #
        def sum_up
          last_active_locking[:amount_cents_saldo_user_counted] + saldo_deposit - saldo_withdraw
        end

        #
        # get the saldo until a given date
        #
        # @param [Date, Time, DateTime] date the date
        #
        # @return [Integer] the saldo until the given date
        #
        def sum_up_until(date)
          last_active_locking[:amount_cents_saldo_user_counted] + saldo_deposit_until(date) - saldo_withdraw_until(date)
        end

        #
        # get the saldo of withdraws since the last locking
        #
        # @return [Integer] the saldo of withdraws since the last locking
        #
        def saldo_withdraw
          bookings_since_last_locking_sum_amount_cents('withdraw', last_active_locking) || 0
        end

        #
        # get the saldo of deposits since the last locking
        #
        # @return [Integer] the saldo of deposits since the last locking
        #
        def saldo_deposit
          bookings_since_last_locking_sum_amount_cents('deposit', last_active_locking) || 0
        end

        #
        # get the saldo of withdraws since the last locking until a given date
        #
        # @param [Date, Time, DateTime] date the date
        #
        # @return [Integer] the saldo of withdraws since the last locking until the given date
        #
        def saldo_withdraw_until(date)
          bookings_since_last_locking_until_date_sum_amount_cents('withdraw', date, last_active_locking) || 0
        end

        #
        # get the saldo of deposits since the last locking until a given date
        #
        # @param [Date, Time, DateTime] date the date
        #
        # @return [Integer] the saldo of deposits since the last locking until the given date
        #
        def saldo_deposit_until(date)
          bookings_since_last_locking_until_date_sum_amount_cents('deposit', date, last_active_locking) || 0
        end

        private

        def bookings_since_last_locking_sum_amount_cents(action, last_active_locking)
          @conn.where(action: action)
               .where { realized > last_active_locking[:realized] }
               .select(Sequel.lit('sum(cast(amount_cents as int)) as saldo '))
               .first[:saldo]
        end

        def bookings_since_last_locking_until_date_sum_amount_cents(action, realized_until, last_active_locking)
          @conn.where(action: action)
               .where { realized > last_active_locking[:realized] }
               .where { realized <= realized_until }
               .select(Sequel.lit('sum(cast(amount_cents as int)) as saldo '))
               .first[:saldo]
        end

        def last_active_locking
          @conn_locking.where(active: true)
                       .order(:realized)
                       .last || last_active_locking_missing_obj
        end

        def last_active_locking_missing_obj
          @last_active_locking_missing_obj ||= { amount_cents_saldo_user_counted: 0,
                                                 saldo_cents_calculated: 0,
                                                 realized: DB::EARLIEST_BOOKING }
        end
      end
    end
  end
end
