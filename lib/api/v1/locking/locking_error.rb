# frozen_string_literal: true

module Api
  module V1
    module Locking
      class LockingError < StandardError
        attr_reader :error_obj

        def initialize(error_obj)
          super
          @error_obj = error_obj
        end
      end
    end
  end
end
