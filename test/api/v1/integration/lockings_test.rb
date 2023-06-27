# frozen_string_literal: true

require 'test_helper'

class TestLockings < ApiIntegrationHelperTest
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
  def test_no_negative_saldo_with_lock_inbetween
    create_bookings!

    uri = '/ka-ching/api/v1/test/bookings'
    req_data = { amount_cents: 1500,
                 action: :withdraw,
                 year: 2022, month: 11, day: 11,
                 context: { account: 1315, text: 'test' } }
    post(uri, JSON.generate(req_data), header_content_type_json)
    json_body = JSON.parse(last_response.body)

    assert_equal(0, json_body['saldo'])
    assert_predicate last_response, :ok?

    uri = '/ka-ching/api/v1/test/lockings'
    req_data = { amount_cents_saldo_user_counted: 1000,
                 action: :lock,
                 year: 2022, month: 11, day: 3 }
    post(uri, JSON.generate(req_data), header_content_type_json)

    refute_predicate last_response, :ok?

    assert_equal(403, last_response.status)
    json_body = JSON.parse(last_response.body)

    assert_equal('Api::V1::Locking::LockingError', json_body['status'])
    assert_equal('Saldo would be negative after locking', json_body['message'])
  end

  #
  # Saldo cannot be negative inbetween.
  #
  def test_no_negative_saldo_with_lock
    create_bookings!

    uri = '/ka-ching/api/v1/test/lockings'
    req_data = { amount_cents_saldo_user_counted: 1500, action: :lock,
                 year: 2022, month: 11, day: 3 }
    post(uri, JSON.generate(req_data), header_content_type_json)

    assert_predicate last_response, :ok?

    uri = '/ka-ching/api/v1/test/bookings'
    req_data = { amount_cents: 4000, action: :withdraw,
                 year: 2022, month: 11, day: 11,
                 context: { account: 1815, text: 'test' } }
    post(uri, JSON.generate(req_data), header_content_type_json)
    json_body = JSON.parse(last_response.body)

    assert_equal(400, last_response.status)
    assert_equal('Api::V1::Booking::BookerError', json_body['status'])
  end

  #
  # Bookings, then locked.
  #
  def test_locking_inbetween
    create_bookings!
    uri = '/ka-ching/api/v1/test/lockings'
    req_data = { amount_cents_saldo_user_counted: 1501, action: :lock,
                 year: 2022, month: 11, day: 2 }
    post(uri, JSON.generate(req_data), header_content_type_json)

    assert_predicate last_response, :ok?
    json_body = JSON.parse(last_response.body)

    assert_equal(1501, json_body['saldo'])
    assert_equal(-499, json_body['diff'])
    assert_equal(1501, json_body['record']['amount_cents_saldo_user_counted'])
    assert_equal(2000, json_body['record']['saldo_cents_calculated'])

    locked_bookings = JSON.parse(json_body['record']['bookings_json'])
    locked_booking = locked_bookings.first

    # try deletion of locked booking
    uri = '/ka-ching/api/v1/test/bookings'
    delete(uri, JSON.generate({ id: locked_booking['id'] }), header_content_type_json)

    assert_equal 400, last_response.status
    json_body = JSON.parse(last_response.body)

    assert_equal('Api::V1::Booking::BookerError', json_body['status'])
    assert_equal('Impossible!', json_body['message'])

    assert(json_body['error_object'].is_a?(Hash))
    error_obj = json_body['error_object']

    assert_equal(%w[
      id
      action
      amount_cents
      realized_at
      context
      created_at
      updated_at
    ].sort, error_obj.keys.sort)

    # check saldo
    get '/ka-ching/api/v1/test/saldo'

    assert_predicate last_response, :ok?
    json_body = JSON.parse(last_response.body)

    assert json_body['saldo'].is_a?(Integer)
    assert_equal(1001, json_body['saldo'])
  end

  def test_pagination_for_lockings
    create_bookings!
    uri = '/ka-ching/api/v1/test/lockings'
    req_data = { amount_cents_saldo_user_counted: 1501, action: :lock,
                 year: 2022, month: 11, day: 2 }
    post(uri, JSON.generate(req_data), header_content_type_json)

    assert_predicate last_response, :ok?

    get '/ka-ching/api/v1/test/lockings/all'

    assert_predicate last_response, :ok?

    assert_equal(%w[
      current_page
      current_page_record_count
      current_page_record_range
      first_page
      last_page
      next_page
      page_count
      page_range
      page_size
      pagination_record_count
      prev_page
      items
    ].sort, JSON.parse(last_response.body).keys.sort)

    assert JSON.parse(last_response.body)['items'].is_a?(Array)
    assert JSON.parse(last_response.body)['items'].first.is_a?(Hash)
  end
end
