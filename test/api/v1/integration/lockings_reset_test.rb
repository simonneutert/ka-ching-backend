# frozen_string_literal: true

require 'test_helper'

class TestLockingsReset < ApiIntegrationHelperTest
  include Rack::Test::Methods
  include Minitest::Hooks

  def type_locking?(locking)
    valid_keys = %w[id saldo_cents_calculated amount_cents_saldo_user_counted realized_at created_at updated_at]
    valid_keys.all? { |k| locking.key?(k) }
  end

  def create_bookings!
    uri = '/ka-ching/api/v1/test/bookings'
    req_data = { amount_cents: 1000, action: :deposit,
                 year: 2022, month: 11, day: 1,
                 context: { account: 1815, text: 'test' } }
    post(uri, JSON.generate(req_data), header_content_type_json)

    req_data = { amount_cents: 1000, action: :deposit,
                 year: 2022, month: 11, day: 2,
                 context: { account: 1815, text: 'test' } }
    post(uri, JSON.generate(req_data), header_content_type_json)

    req_data = { amount_cents: 500, action: :withdraw,
                 year: 2022, month: 11, day: 3,
                 context: { account: 1815, text: 'test' } }
    post(uri, JSON.generate(req_data), header_content_type_json)
  end

  #
  # Saldo cannot be negative.
  #
  def test_reset
    create_bookings!
    get '/ka-ching/api/v1/test/saldo'

    assert_predicate last_response, :ok?

    json_body = JSON.parse(last_response.body)

    assert json_body['saldo'].is_a?(Integer)
    assert_equal 1500, json_body['saldo']

    uri = '/ka-ching/api/v1/test/bookings/unlocked'
    get(uri, {}, header_content_type_json)

    assert_predicate last_response, :ok?
    json_body = JSON.parse(last_response.body)

    assert json_body['bookings'].is_a?(Array)
    assert_equal 3, json_body['bookings'].size

    ### RESET

    uri = '/ka-ching/api/v1/admin/test/reset'
    post(uri, {}, header_content_type_json)

    get '/ka-ching/api/v1/test/saldo'

    assert_predicate last_response, :ok?

    json_body = JSON.parse(last_response.body)

    assert json_body['saldo'].is_a?(Integer)
    assert_equal 0, json_body['saldo']

    assert_predicate last_response, :ok?

    uri = '/ka-ching/api/v1/test/bookings/unlocked'
    get(uri, {}, header_content_type_json)

    assert_predicate last_response, :ok?
    json_body = JSON.parse(last_response.body)

    assert json_body['bookings'].is_a?(Array)
    assert_equal 0, json_body['bookings'].size
  end
end
