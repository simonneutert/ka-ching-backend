# frozen_string_literal: true

require 'test_helper'

class TestBookingParams < ApiIntegrationHelperTest
  include Rack::Test::Methods
  include Minitest::Hooks

  def setup
    @booking_param_caster = Api::V1::Booking::ParamsCaster
  end

  def test_missing_key_in_params
    error = assert_raises(KeyError) do
      @booking_param_caster.new({ 'action' => 'deposit' })
    end

    assert_includes(error.message, 'amount_cents')
  end

  def test_value_not_castable_from_params
    error = assert_raises(ArgumentError) do
      @booking_param_caster.new({ 'action' => 'deposit',
                                  'amount_cents' => 'a lot of money' })
    end

    assert_includes(error.message, 'invalid value for Integer')
  end

  def test_booking_from_params
    booking = @booking_param_caster.new(
      {
        'action' => 'deposit',
        'amount_cents' => 1000,
        'year' => 2022,
        'month' => 10,
        'day' => 11,
        'context' => {
          'message' => 'I am a booking for account 123'
        }
      }
    )

    assert_equal('deposit', booking.action)
    assert_equal(1000, booking.amount_cents)
    assert_equal(2022, booking.year)
    assert_equal(10, booking.month)
    assert_equal(11, booking.day)
    assert_kind_of(String, booking.context.to_json)
    assert_empty(%i[@action @amount_cents @year @month @day @context] - booking.instance_variables)
  end
end
