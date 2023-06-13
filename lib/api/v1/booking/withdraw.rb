# frozen_string_literal: true

module Api
  module V1
    module Booking
      class Withdraw
        include Api::V1::Helper::Repository

        attr_reader :tenant_db_connector,
                    :booker

        def initialize(conn, booker)
          @conn = conn
          @conn_bookings = conn[:bookings]
          @booker = booker
        end

        #
        # Book a withdrawal
        #
        # @return [Hash] representing the new booking
        #
        def book!
          # 1. connect to db with lock
          # 2. append booking
          # 3. return new saldo
          # 4. release lock
          validate!
          @conn.transaction do
            @conn.run('LOCK TABLE lockings IN ACCESS EXCLUSIVE MODE')
            @conn.run('LOCK TABLE bookings IN ACCESS EXCLUSIVE MODE')
            new_booking_id = @conn_bookings.insert(id: SecureRandom.uuid,
                                                   amount_cents: @booker.amount_cents,
                                                   action: @booker.action,
                                                   realized_at: @booker.realized_at,
                                                   context: @booker.context.to_json)

            query_bookings(@conn).find_by(id: new_booking_id)
          end
        end

        private

        def validate!
          latest_locking_realized_at = query_lockings(@conn).latest_active[:realized_at]
          validate_open!(latest_locking_realized_at)
          validate_saldo_positive!(latest_locking_realized_at)
        end

        def validate_saldo_positive!(latest_locking_realized_at)
          current_saldo = Api::V1::Repository::Saldo.new(@conn).sum_up_until(@booker.realized_at)
          return latest_locking_realized_at unless (current_saldo - @booker.amount_cents).negative?

          raise Api::V1::Booking::BookerError.new('Booking not possible, saldo cannot be negative!',
                                                  error_obj: { current_saldo: current_saldo,
                                                               withdraw_amount_cent: @booker.amount_cents })
        end

        def validate_open!(latest_locking_realized_at)
          return if @booker.realized_at > latest_locking_realized_at

          raise Api::V1::Booking::BookerError, 'Booking not possible, locked for this day!'
        end
      end
    end
  end
end
