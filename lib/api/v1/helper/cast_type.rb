# frozen_string_literal: true

module Api
  module V1
    module Helper
      module CastType
        def cast!(val, type)
          case type.to_s.to_sym
          when :String
            val.is_a?(String) ? val : val.to_s
          when :Integer
            Integer val
          when :Symbol
            val.to_sym
          when :Float
            Float val
          end
        end
      end
    end
  end
end
