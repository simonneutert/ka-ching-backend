# frozen_string_literal: true

module Api
  module V1
    module Booking
      class Deposit
        include Api::V1::Helper::Repository

        attr_reader :tenant_db_connector,
                    :booker

        def initialize(conn, booker)
          @conn = conn
          @conn_bookings = @conn[:bookings]
          @conn_lockings = @conn[:lockings]
          @booker = booker
        end

        #
        # Book a deposit
        #
        # @return [Hash] representing the new booking
        #
        def book!
          # 1. connect to db with lock
          # 2. append booking
          # 3. return new saldo
          # 4. release lock
          @conn.transaction do
            @conn.run('LOCK TABLE lockings IN ACCESS EXCLUSIVE MODE')
            @conn.run('LOCK TABLE bookings IN ACCESS EXCLUSIVE MODE')
            validate!
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
          validate_not_locked!
        end

        def validate_not_locked!
          latest_locking_realized_at = query_lockings(@conn).latest_active[:realized_at]
          unless @booker.realized_at > latest_locking_realized_at
            raise BookerError, 'Booking not possible, locked for this day.'
          end

          latest_locking_realized_at
        end
      end
    end
  end
end
