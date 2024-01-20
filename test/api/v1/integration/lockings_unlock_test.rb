# frozen_string_literal: true

require 'test_helper'

class TestLockingsUnlock < ApiIntegrationHelperTest
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

    get '/ka-ching/api/v1/test/saldo'

    assert_predicate last_response, :ok?
    json_body = JSON.parse(last_response.body)

    assert_kind_of Integer, json_body['saldo']
    assert_equal(1001, json_body['saldo'])
  end

  #
  # the last locking must not be unlocked, if newer bookings are present.
  #
  def test_lockings_unlock_latest_if_no_newer_bookings_present
    create_bookings!

    uri = '/ka-ching/api/v1/test/lockings'
    req_data = { amount_cents_saldo_user_counted: 1501, action: :lock,
                 year: 2022, month: 11, day: 2 }
    post(uri, JSON.generate(req_data), header_content_type_json)
    json_body = JSON.parse(last_response.body)
    bookings = json_body['record']['bookings']

    assert_equal(-499, json_body['diff'])
    assert_equal(2, bookings.count)

    uri = '/ka-ching/api/v1/test/lockings'
    delete(uri, {}, header_content_type_json)

    assert_equal(403, last_response.status)
    refute_predicate last_response, :ok?
    json_body = JSON.parse(last_response.body)

    assert_equal('Api::V1::Locking::DeactivatorError', json_body['status'])
    assert_equal('You can unlock the last lock only, now go wash your hands!', json_body['message'])
  end

  #
  # Only one, specifically the last locking, should be unlockable.
  #
  def test_lockings_unlock_latest_only
    create_bookings!

    uri = '/ka-ching/api/v1/test/lockings'
    req_data = { amount_cents_saldo_user_counted: 2001, action: :lock,
                 year: 2022, month: 11, day: 2 }
    post(uri, JSON.generate(req_data), header_content_type_json)
    json_body = JSON.parse(last_response.body)
    bookings = json_body['record']['bookings']

    assert_equal(1, json_body['diff'])
    assert_equal(2, bookings.count)

    uri = '/ka-ching/api/v1/test/lockings'
    delete(uri, {}, header_content_type_json)

    refute_predicate last_response, :ok?
    assert_equal 403, last_response.status

    uri = '/ka-ching/api/v1/test/lockings'
    req_data = { amount_cents_saldo_user_counted: 2000, action: :lock,
                 year: 2022, month: 11, day: 2 }
    post(uri, JSON.generate(req_data), header_content_type_json)

    refute_predicate last_response, :ok?
    assert_equal 403, last_response.status

    uri = '/ka-ching/api/v1/test/lockings'
    req_data = { amount_cents_saldo_user_counted: 1500, action: :lock,
                 year: 2022, month: 11, day: 3 }
    post(uri, JSON.generate(req_data), header_content_type_json)

    assert_predicate last_response, :ok?
    json_body = JSON.parse(last_response.body)

    assert_equal(-1, json_body['diff'])
    json_body = JSON.parse(last_response.body)
    bookings = json_body['record']['bookings']

    assert_equal(1, bookings.count)

    uri = '/ka-ching/api/v1/test/lockings'
    delete(uri, {}, header_content_type_json)

    assert_predicate last_response, :ok?

    uri = '/ka-ching/api/v1/test/lockings'
    get(uri, { year: 2022 }, header_content_type_json)

    assert_predicate last_response, :ok?
    json_body = JSON.parse(last_response.body)

    refute_empty json_body['items']
    assert_kind_of Array, json_body['items']
    assert_equal(2, json_body['items'].count)

    latest_locking, *other_bookings = json_body['items']
    first_locking = other_bookings.last

    assert_equal(2, first_locking['bookings'].count)
    assert_equal(1, latest_locking['bookings'].count)

    uri = '/ka-ching/api/v1/test/lockings'
    delete(uri, {}, header_content_type_json)

    assert_equal(403, last_response.status)
    refute_predicate last_response, :ok?
    json_body = JSON.parse(last_response.body)

    assert_equal('Api::V1::Locking::DeactivatorError', json_body['status'])
    assert_equal('You can unlock the last lock only, now go wash your hands!', json_body['message'])
  end

  #
  # Unlocking, locking, the last lock is possibly. Locking in-between not.
  #
  def test_lockings_multiple_successful_locks_per_day
    create_bookings!

    uri = '/ka-ching/api/v1/test/lockings'
    req_data = { amount_cents_saldo_user_counted: 1501, action: :lock,
                 year: 2022, month: 11, day: 2 }
    post(uri, JSON.generate(req_data), header_content_type_json)

    json_body = JSON.parse(last_response.body)

    bookings_in_lock = json_body.dig('record', 'bookings')

    assert_equal 2, bookings_in_lock.count
    assert_equal(-499, json_body['diff'])

    uri = '/ka-ching/api/v1/test/lockings'
    delete(uri, {}, header_content_type_json)

    assert_equal(403, last_response.status)
    refute_predicate last_response, :ok?
    # json_body = JSON.parse(last_response.body)

    uri = '/ka-ching/api/v1/test/lockings'
    req_data = { amount_cents_saldo_user_counted: 2000, action: :lock,
                 year: 2022, month: 11, day: 2 }
    post(uri, JSON.generate(req_data), header_content_type_json)

    assert_equal(403, last_response.status)
    refute_predicate last_response, :ok?
    # json_body = JSON.parse(last_response.body)

    uri = '/ka-ching/api/v1/test/lockings'
    req_data = { amount_cents_saldo_user_counted: 1001, action: :lock,
                 year: 2022, month: 11, day: 3 }
    post(uri, JSON.generate(req_data), header_content_type_json)

    assert_predicate last_response, :ok?
    json_body = JSON.parse(last_response.body)
    bookings_in_lock = json_body.dig('record', 'bookings')

    assert_equal 1, bookings_in_lock.count
    assert_equal 0, json_body['diff']

    uri = '/ka-ching/api/v1/test/lockings'
    delete(uri, {}, header_content_type_json)

    assert_predicate last_response, :ok?

    uri = '/ka-ching/api/v1/test/lockings'
    req_data = { amount_cents_saldo_user_counted: 1000, action: :lock,
                 year: 2022, month: 11, day: 3 }
    post(uri, JSON.generate(req_data), header_content_type_json)

    assert_predicate last_response, :ok?
    json_body = JSON.parse(last_response.body)

    bookings_in_lock = json_body.dig('record', 'bookings')

    assert_equal 1, bookings_in_lock.count
    assert_equal(-1, json_body['diff'])

    uri = '/ka-ching/api/v1/test/lockings'
    delete(uri, {}, header_content_type_json)

    assert_predicate last_response, :ok?

    uri = '/ka-ching/api/v1/test/lockings'
    req_data = { amount_cents_saldo_user_counted: 1002, action: :lock,
                 year: 2022, month: 11, day: 3 }
    post(uri, JSON.generate(req_data), header_content_type_json)

    assert_predicate last_response, :ok?
    json_body = JSON.parse(last_response.body)

    assert_equal 1, json_body['diff']

    uri = '/ka-ching/api/v1/test/lockings'
    req_data = { amount_cents_saldo_user_counted: 1500, action: :lock,
                 year: 2022, month: 11, day: 2 }
    post(uri, JSON.generate(req_data), header_content_type_json)

    refute_predicate last_response, :ok?
    json_body = JSON.parse(last_response.body)

    assert_equal('Api::V1::Locking::LockingError', json_body['status'])
    assert_equal('There is already a newer lock in place!', json_body['message'])
  end
end
