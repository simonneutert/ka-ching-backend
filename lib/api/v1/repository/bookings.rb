# frozen_string_literal: true

module Api
  module V1
    module Repository
      class Bookings
        include Api::V1::Helper::DatabaseConnection

        def initialize(conn)
          @conn = conn
          @conn_bookings = conn[:bookings]
        end

        #
        # get a booking by id
        #
        # @param [String] id uuid of the booking
        #
        # @return [Hash] returns the booking
        #
        def find_by(id:)
          @conn_bookings.where(id: id).first
        end

        #
        # delete a booking by id
        #
        # @param [String] id uuid of the booking
        #
        # @return [Hash] returns the booking and deleted flag
        #
        def delete_by(id:)
          booking = find_by(id: id)
          res = @conn_bookings.where(id: id).delete
          { booking: booking, deleted: res }
        end

        #
        # get all bookings that are active
        #
        # @param [Date, Time, DateTime] last_locking_realized
        # @param [Symbol] order column to order by
        #
        # @return [Array<Hash>] list of bookings
        #
        def active(last_locking_realized_at, order: :created_at)
          @conn_bookings.where { realized_at > last_locking_realized_at }.order(order).all
        end

        #
        # get pagination of bookings that are active
        #
        # @param [Date, Time, DateTime] last_locking_realized_at
        # @param [Symbol] order column to order by
        #
        # @return [Array<Hash>] list of bookings
        #
        def active_paginated(last_locking_realized_at, order: :created_at, page: 1, per_page: 100)
          @conn_bookings.paginate(page, per_page).where { realized_at > last_locking_realized_at }.order(order).all
        end
      end
    end
  end
end
