# frozen_string_literal: true

module Api
  module V1
    module Booking
      class BookerError < StandardError
        attr_reader :error_obj

        def initialize(message, error_obj: nil)
          super(message)
          @error_obj = error_obj
        end
      end
    end
  end
end
