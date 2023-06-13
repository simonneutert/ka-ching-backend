# frozen_string_literal: true

module Api
  module V1
    module Booking
      #
      # use this class for other class to extrude and cast params
      #
      class ParamsCaster < Api::V1::ParamsCaster
        # @!attribute action
        # @return [String] action to perform
        # @!attribute amount_cents
        # @return [Integer] amount of the booking
        # @!attribute year
        # @return [Integer] year of the booking
        # @!attribute month
        # @return [Integer] month of the booking
        # @!attribute day
        # @return [Integer] day of the booking
        # @!attribute context
        # @return [Hash] context of the booking
        def initialize(*args)
          @obj_attributes = {
            'action' => String,
            'amount_cents' => Integer,
            'year' => Integer,
            'month' => Integer,
            'day' => Integer,
            'context' => Hash
          }.freeze
          super
        end

        #
        # @return [Time] the time of the booking
        #
        def build_realized_at
          Time.new(@year, @month, @day)
        end
      end
    end
  end
end
