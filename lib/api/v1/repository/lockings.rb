# frozen_string_literal: true

module Api
  module V1
    module Repository
      class Lockings
        include Api::V1::Helper::DatabaseConnection

        def initialize(conn)
          @conn = conn
          @conn_lockings = conn[:lockings]
        end

        #
        # Returns all lockings paginated
        #
        # @param [Integer] page page number
        # @param [Integer] per_page number of lockings per page
        #
        # @return [Hash] pagination result with items key holding the lockings
        #
        def all(page: 1, per_page: 10, order: :realized_at, direction: :desc)
          if direction.to_sym == :desc
            result_paginated(@conn_lockings.order(Sequel.desc(order)), Integer(page), Integer(per_page))
          else
            result_paginated(@conn_lockings.order(order), Integer(page), Integer(per_page))
          end
        end

        #
        # get a locking by id
        #
        # @param [String] id the uuid of the locking
        #
        # @return [Hash] the locking
        #
        def find_by(id:)
          @conn_lockings.where(id:).first
        end

        #
        # returns the last realized_at and active locking
        #
        # @param [Date, Time, DateTime] before_date_or_time the date or time
        #
        # @return [Hash] the locking
        #
        def last_active_realized_at(before_date_or_time: nil)
          @conn_lockings.where(active: true)
                        .where { realized_at < before_date_or_time }
                        .order(:realized_at).last
        end

        #
        # returns all lockings in a date range ordered by realized
        #
        # @param [Rage<Date, Time, DateTime>] date_range the date range
        #
        # @return [Array<Hash>] list of lockings
        #
        def in_date_range_order_realized_at_desc(date_range)
          @conn_lockings.order(Sequel.desc(:realized_at))
                        .where(realized_at: date_range)
        end

        #
        # returns all active lockings in a date range ordered by realized
        #
        # @param [Range<Date, Time, DateTime>] date_range the date range
        #
        # @return [Array<Hash>] list of lockings
        #
        def active_in_date_range_order_realized_at_desc(date_range)
          @conn_lockings.order(Sequel.desc(:realized_at))
                        .where(realized_at: date_range)
                        .where(active: true)
        end

        #
        # returns all inactive lockings in a date range ordered by realized
        #
        # @param [Range<Date, Time, DateTime] date_range the date range
        #
        # @return [Array<Hash>] list of lockings
        #
        def inactive_in_date_range_order_realized_at_desc(date_range)
          @conn_lockings.order(Sequel.desc(:realized_at))
                        .where(realized_at: date_range)
                        .where(active: false)
        end

        #
        # returns latest active locking or a locking with a date in the past
        #
        # @return [Hash] the locking
        #
        def latest_active
          locking = @conn_lockings.order(:realized_at)
                                  .where(active: true)
                                  .last
          locking || locking_never_locked
        end

        private

        def locking_never_locked
          { realized_at: DB::EARLIEST_BOOKING }
        end
      end
    end
  end
end
