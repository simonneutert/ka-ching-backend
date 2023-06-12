# frozen_string_literal: true

module Api
  module V1
    module Locking
      #
      # use this class for other class to extrude and cast params
      #
      class ParamsCaster < Api::V1::ParamsCaster
        # @!attribute action
        # @return [String] action to perform
        # @!attribute amount_cents_saldo_user_counted
        # @return [Integer] amount_cents_saldo_user_counted calculated
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
            'action' => [String],
            'amount_cents_saldo_user_counted' => [Integer],
            'year' => [Integer],
            'month' => [Integer],
            'day' => [Integer],
            'context' => [Hash, { optional: true }]
          }.freeze
          super
        end
      end
    end
  end
end
