# frozen_string_literal: true

require 'test_helper'

class TestSaldoSimple < ApiIntegrationHelperTest
  include Rack::Test::Methods
  include Minitest::Hooks

  #
  # No bookings.
  #
  def test_empty_saldo
    get '/ka-ching/api/v1/test/saldo'

    assert_predicate last_response, :ok?

    json_body = JSON.parse(last_response.body)

    assert_kind_of Integer, json_body['saldo']
    assert_equal 0, json_body['saldo']
  end

  #
  # No negative saldo.
  #
  def test_first_booking_saldo_negative
    uri = '/ka-ching/api/v1/test/bookings'
    req_data = { amount_cents: 1, action: :withdraw,
                 year: 2022, month: 11, day: 11,
                 context: { account: 1815, text: 'test' } }
    post(uri, JSON.generate(req_data), header_content_type_json)

    assert_equal 400, last_response.status
  end
end
