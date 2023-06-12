# frozen_string_literal: true

module Api
  module V1
    #
    # use this class for other class to extrude and cast params
    # i.e., like this:
    #
    #   def initialize(*args)
    #     @obj_attributes = { 'action' => [String],
    #       'amount_cents_saldo_user_counted' => [Integer],
    #       'year' => [Integer],
    #       'month' => [Integer],
    #       'day' => [Integer],
    #       'context' => [Hash, { optional: true }] }.freeze
    #     super
    #   end
    #
    class ParamsCaster
      include Api::V1::Helper::CastType

      # @!attribute obj_attributes
      #  @return [Hash{String => Array<Class, Hash>}] see example in class comment
      attr_reader :obj_attributes, :params

      def initialize(params)
        @params = Marshal.load(Marshal.dump(params.dup))
        extrude!
      end

      private

      #
      # extrude the params and cast them to the given type
      #
      # @return [Object] the casted object as the given type
      #
      def extrude!
        @obj_attributes.each do |attr, (type, opts)|
          instance_variable_set("@#{attr}", dynamic_cast(attr, type))
        rescue KeyError => e
          raise e unless opts && opts[:optional]

          instance_variable_set("@#{attr}", type.new)
        ensure
          self.class.class_eval { attr_reader attr.to_sym }
        end
      end

      #
      # cast the attr to the type dynamically
      #
      # @param [String,Symbol] attr attribute to cast
      # @param [Object] type type to cast to, i.e., String, Integer, etc.
      #
      # @return [Object] the casted object
      #
      def dynamic_cast(attr, type)
        return @params.fetch(attr) if @params.fetch(attr).is_a?(type)

        cast!(@params.fetch(attr), type)
      end
    end
  end
end
