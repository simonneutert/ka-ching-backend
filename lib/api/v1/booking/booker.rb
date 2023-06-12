# frozen_string_literal: true

module Api
  module V1
    module Booking
      class Booker
        include Api::V1::Helper::Repository

        attr_reader :tenant_db_connector,
                    :amount_cents,
                    :action,
                    :realized,
                    :context

        def initialize(conn, params)
          @conn = conn
          cast_params!(params)
          raise unless @amount_cents.positive?
        end

        #
        # Book a deposit or withdrawal
        #
        # @return [Hash]
        #
        def book!
          booker_service = decide_booker_service_by_action
          new_booking = booker_service.book!

          { status: !new_booking.nil?,
            saldo: query_saldos(@conn).sum_up,
            record: new_booking,
            context: new_booking['context'] }
        end

        private

        def decide_booker_service_by_action
          case @action
          when 'deposit'
            Deposit.new(@conn, self)
          when 'withdraw'
            Withdraw.new(@conn, self)
          else
            raise ArgumentError, 'Not known action!'
          end
        end

        def cast_params!(params)
          Api::V1::Booking::ParamsCaster.new(params).tap do |casted_params|
            @action = casted_params.action
            @amount_cents = casted_params.amount_cents
            @context = casted_params.context
            @realized = casted_params.build_realized
          end
        end
      end
    end
  end
end
