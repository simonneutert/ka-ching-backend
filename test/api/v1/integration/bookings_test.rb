# frozen_string_literal: true

require 'test_helper'

class TestBookings < ApiIntegrationHelperTest
  include Rack::Test::Methods
  include Minitest::Hooks

  def type_locking?(locking)
    valid_keys = %w[id saldo_cents_calculated amount_cents_saldo_user_counted realized created_at updated_at]
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

  def test_sum_up_at_day
    uri = '/ka-ching/api/v1/test/bookings'
    req_data = { amount_cents: 1000, action: :deposit,
                 year: 2022, month: 11, day: 1,
                 context: { account: 1815, text: 'test' } }
    post(uri, JSON.generate(req_data), header_content_type_json)

    assert_predicate last_response, :ok?

    uri = '/ka-ching/api/v1/test/bookings'
    req_data = { amount_cents: 100, action: :withdraw,
                 year: 2022, month: 11, day: 1,
                 context: { account: 1815, text: 'test' } }
    post(uri, JSON.generate(req_data), header_content_type_json)

    assert_predicate last_response, :ok?

    uri = '/ka-ching/api/v1/test/bookings'
    req_data = { amount_cents: 1000, action: :deposit,
                 year: 2022, month: 11, day: 1,
                 context: { account: 1815, text: 'test' } }
    post(uri, JSON.generate(req_data), header_content_type_json)

    assert_predicate last_response, :ok?

    uri = '/ka-ching/api/v1/test/bookings'
    req_data = { amount_cents: 500, action: :withdraw,
                 year: 2022, month: 11, day: 1,
                 context: { account: 1815, text: 'test' } }
    post(uri, JSON.generate(req_data), header_content_type_json)

    assert_predicate last_response, :ok?

    uri = '/ka-ching/api/v1/test/saldo/current'
    get(uri, nil, header_content_type_json)

    assert_predicate last_response, :ok?
    json_body = JSON.parse(last_response.body)

    assert_equal 1400, json_body['saldo']

    uri = '/ka-ching/api/v1/test/bookings'
    req_data = { amount_cents: 1000, action: :deposit,
                 year: 2022, month: 11, day: 3,
                 context: { account: 1815, text: 'test' } }
    post(uri, JSON.generate(req_data), header_content_type_json)

    assert_predicate last_response, :ok?

    uri = '/ka-ching/api/v1/test/saldo/current'
    get(uri, nil, header_content_type_json)

    assert_predicate last_response, :ok?
    json_body = JSON.parse(last_response.body)

    assert_equal 2400, json_body['saldo']

    uri = '/ka-ching/api/v1/test/bookings'
    req_data = { amount_cents: 1401, action: :withdraw,
                 year: 2022, month: 11, day: 2,
                 context: { account: 1815, text: 'test' } }
    post(uri, JSON.generate(req_data), header_content_type_json)

    assert_equal(400, last_response.status)
    assert_includes last_response.body, 'Api::V1::Booking::BookerError'
    assert_includes last_response.body, 'saldo cannot be negative'
    assert_includes last_response.body, '"current_saldo":1400'

    uri = '/ka-ching/api/v1/test/bookings'
    req_data = { amount_cents: 1400, action: :withdraw,
                 year: 2022, month: 11, day: 2,
                 context: { account: 1815, text: 'test' } }
    post(uri, JSON.generate(req_data), header_content_type_json)

    assert_predicate last_response, :ok?

    uri = '/ka-ching/api/v1/test/saldo/current'
    get(uri, nil, header_content_type_json)

    assert_predicate last_response, :ok?
    json_body = JSON.parse(last_response.body)

    assert_equal 1000, json_body['saldo']
  end

  #
  # Saldo cannot be negative.
  #
  def test_no_negative_saldo
    create_bookings!

    uri = '/ka-ching/api/v1/test/bookings'
    req_data = { amount_cents: 4000, action: :withdraw,
                 year: 2022, month: 11, day: 11,
                 context: { account: 1815, text: 'test' } }
    post(uri, JSON.generate(req_data), header_content_type_json)
    json_body = JSON.parse(last_response.body)

    assert_equal 400, last_response.status
    assert_equal('Api::V1::Booking::BookerError', json_body['status'])
  end

  #
  # Saldo cannot be negative.
  #
  def test_no_negative_saldo_in_between
    uri = '/ka-ching/api/v1/test/bookings'
    req_data = { amount_cents: 1000, action: :deposit,
                 year: 2022, month: 11, day: 1,
                 context: { account: 1815, text: 'test' } }
    post(uri, JSON.generate(req_data), header_content_type_json)

    req_data = { amount_cents: 1000, action: :deposit,
                 year: 2022, month: 11, day: 3,
                 context: { account: 1815, text: 'test' } }
    post(uri, JSON.generate(req_data), header_content_type_json)

    uri = '/ka-ching/api/v1/test/bookings'
    req_data = { amount_cents: 1500, action: :withdraw,
                 year: 2022, month: 11, day: 2,
                 context: { account: 1815, text: 'test' } }
    post(uri, JSON.generate(req_data), header_content_type_json)
    json_body = JSON.parse(last_response.body)

    assert_equal 400, last_response.status
    assert_equal('Api::V1::Booking::BookerError', json_body['status'])
  end

  #
  # Saldo cannot be negative.
  #
  def test_no_negative_saldo_in_between2
    uri = '/ka-ching/api/v1/test/bookings'
    req_data = { amount_cents: 1000, action: :deposit,
                 year: 2022, month: 11, day: 1,
                 context: { account: 1815, text: 'test' } }
    post(uri, JSON.generate(req_data), header_content_type_json)

    uri = '/ka-ching/api/v1/test/lockings'
    req_data = { amount_cents_saldo_user_counted: 999, action: :lock,
                 year: 2022, month: 11, day: 1 }
    post(uri, JSON.generate(req_data), header_content_type_json)

    assert_predicate last_response, :ok?

    uri = '/ka-ching/api/v1/test/bookings'
    req_data = { amount_cents: 1000, action: :deposit,
                 year: 2022, month: 11, day: 2,
                 context: { account: 1815, text: 'test' } }
    post(uri, JSON.generate(req_data), header_content_type_json)

    json_body = JSON.parse(last_response.body)

    assert_equal 200, last_response.status
    assert_equal 1999, json_body['saldo']

    req_data = { amount_cents: 2000, action: :withdraw,
                 year: 2022, month: 11, day: 2,
                 context: { account: 1815, text: 'test' } }
    post(uri, JSON.generate(req_data), header_content_type_json)
    json_body = JSON.parse(last_response.body)

    assert_equal 400, last_response.status
    assert_equal('Api::V1::Booking::BookerError', json_body['status'])

    uri = '/ka-ching/api/v1/test/bookings'
    req_data = { amount_cents: 1999, action: :withdraw,
                 year: 2022, month: 11, day: 2,
                 context: { account: 1815, text: 'test' } }
    post(uri, JSON.generate(req_data), header_content_type_json)
    json_body = JSON.parse(last_response.body)

    assert_equal 200, last_response.status
    assert_equal 0, json_body['saldo']
  end

  #
  # Bookings with wrong params.
  #
  def test_not_known_action
    uri = '/ka-ching/api/v1/test/bookings'

    req_data = { amount_cents: 1000, action: :rofl_copter,
                 year: 2022, month: 11, day: 11,
                 context: { account: 1815, text: 'test' } }
    post(uri, JSON.generate(req_data), header_content_type_json)
    json_body = JSON.parse(last_response.body)

    assert_equal(400, last_response.status)
    assert_equal('ArgumentError', json_body['status'])
    assert_equal('Not known action!', json_body['message'])
  end

  #
  # Single Booking.
  #
  def test_first_booking_no_lockings
    uri = '/ka-ching/api/v1/test/bookings'

    req_data = { amount_cents: 1000, action: :deposit,
                 year: 2022, month: 11, day: 11,
                 context: { account: 1815, text: 'test' } }
    post(uri, JSON.generate(req_data), header_content_type_json)
    json_body = JSON.parse(last_response.body)

    assert_predicate last_response, :ok?
    assert json_body['saldo'].is_a?(Integer)
    refute_empty json_body['record']
    assert json_body['record']['id'].is_a?(String)
    assert json_body['record']['amount_cents'].is_a?(Integer)
    assert Time.parse(json_body['record']['realized_at'])
  end

  #
  # Bookings, never locked.
  #
  def test_bookings_no_lockings_with_saldo
    create_bookings!

    json_body = JSON.parse(last_response.body)

    assert_predicate last_response, :ok?
    assert json_body['saldo'].is_a?(Integer)
    assert_equal(1500, json_body['saldo'])
  end

  def test_bookings_deletion_rules
    create_bookings!

    json_body = JSON.parse(last_response.body)
    uuid_of_last_booking = json_body.dig('record', 'id')

    uri = '/ka-ching/api/v1/test/bookings'
    delete(uri, JSON.generate({ id: uuid_of_last_booking }), header_content_type_json)

    assert_equal 200, last_response.status
    json_body = JSON.parse(last_response.body)

    assert(json_body['status'])
    assert_kind_of(Hash, json_body['record'])
    assert_equal(uuid_of_last_booking, json_body['record']['deleted']['id'])
    assert_kind_of(String, json_body['record']['deleted']['context'])

    uri = '/ka-ching/api/v1/test/lockings'
    req_data = { amount_cents_saldo_user_counted: 1999, action: :lock,
                 year: 2022, month: 11, day: 3 }
    post(uri, JSON.generate(req_data), header_content_type_json)

    assert_predicate last_response, :ok?

    uuid_of_last_booking = DB::DATABASE_TENANT_TEST_CONN[:bookings].order(:realized_at).all.last[:id]
    uri = '/ka-ching/api/v1/test/bookings'
    delete(uri, JSON.generate({ id: uuid_of_last_booking }), header_content_type_json)
    json_body = JSON.parse(last_response.body)

    assert_equal 400, last_response.status

    assert_equal(%w[status message error_object], json_body.keys)
  end

  #
  # Bookings in timeline with locks applied.
  #
  def test_bookings_timeline
    create_bookings!

    json_body = JSON.parse(last_response.body)

    assert_predicate last_response, :ok?
    assert json_body['saldo'].is_a?(Integer)
    assert_equal(1500, json_body['saldo'])

    uri = '/ka-ching/api/v1/test/lockings'
    req_data = { amount_cents_saldo_user_counted: 1501, action: :lock,
                 year: 2022, month: 11, day: 3 }
    post(uri, JSON.generate(req_data), header_content_type_json)
    # json_body = JSON.parse(last_response.body)
    assert_predicate last_response, :ok?

    get '/ka-ching/api/v1/test/saldo'

    assert_predicate last_response, :ok?
    json_body = JSON.parse(last_response.body)

    assert json_body['saldo'].is_a?(Integer)
    assert_equal(1501, json_body['saldo'])

    uri = '/ka-ching/api/v1/test/bookings'

    req_data = { amount_cents: 1000, action: :deposit,
                 year: 2022, month: 11, day: 4,
                 context: { account: 1815, text: 'test' } }
    post(uri, JSON.generate(req_data), header_content_type_json)
    json_body = JSON.parse(last_response.body)

    assert json_body['saldo'].is_a?(Integer)
    assert_equal(2501, json_body['saldo'])

    uri = '/ka-ching/api/v1/test/lockings'
    req_data = { amount_cents_saldo_user_counted: 1501, action: :lock,
                 year: 2022, month: 11, day: 2 }
    post(uri, JSON.generate(req_data), header_content_type_json)

    refute_predicate last_response, :ok?
    json_body = JSON.parse(last_response.body)

    assert_equal('Api::V1::Locking::LockingError', json_body['status'])
    assert_equal('There is already a newer lock in place!', json_body['message'])

    get '/ka-ching/api/v1/test/saldo'

    assert_predicate last_response, :ok?
    json_body = JSON.parse(last_response.body)

    assert json_body['saldo'].is_a?(Integer)
    assert_equal(2501, json_body['saldo'])

    get '/ka-ching/api/v1/test/lockings', { active: true, year: 2022 }

    assert_predicate last_response, :ok?
    json_body = JSON.parse(last_response.body)

    refute_empty json_body
    assert json_body.is_a?(Hash)
    assert_equal(1, json_body['items'].count)

    lockings = json_body['items']
    locking = lockings.first

    assert type_locking?(locking)
  end
end
