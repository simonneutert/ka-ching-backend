# frozen_string_literal: true

module Api
  module V1
    module Booking
      class Deleter
        include Api::V1::Helper::Repository

        attr_reader :tenant_db_connector,
                    :uuid

        def initialize(conn, uuid)
          @conn = conn
          @uuid = uuid
        end

        #
        # deletes an unlocked booking
        #
        # @return [Hash{Symbol => TrueClass,Object}]
        #
        def delete!
          @conn.transaction do
            @conn.run('LOCK TABLE lockings IN ACCESS EXCLUSIVE MODE')
            @conn.run('LOCK TABLE bookings IN ACCESS EXCLUSIVE MODE')
            booking = query_bookings(@conn).find_by(id: @uuid)
            last_locking = query_lockings(@conn).latest_active
            unless deleted?(booking: booking, last_locking: last_locking)
              raise Api::V1::Booking::BookerError.new('Impossible!', error_obj: booking)
            end

            { status: true,
              record: { deleted: booking } }
          end
        end

        private

        def deleted?(booking:, last_locking:)
          deletable?(booking: booking, last_locking: last_locking) &&
            query_bookings(@conn).delete_by(id: @uuid)[:deleted] == 1
        end

        def deletable?(booking:, last_locking:)
          booking[:realized].to_date > last_locking[:realized].to_date
        end

        def validate!
          raise Api::V1::Booking::BookerError unless valid_unlocked!
        end

        def valid_unlocked!
          latest_lock_realized = query_lockings(@conn).latest_active[:realized]
          booking = query_bookings(@conn).find_by(id: @uuid)
          booking && booking[:realized] > latest_lock_realized
        end
      end
    end
  end
end
