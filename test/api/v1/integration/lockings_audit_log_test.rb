# frozen_string_literal: true

require 'test_helper'

class TestLockingsAuditLog < ApiIntegrationHelperTest
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
  # Sample Bookings, locked one time, AuditLog entries, unlocked after.
  #
  def test_locking_deactivate
    get('/ka-ching/api/v1/test/lockings', { year: 2022, active: true })

    assert_predicate last_response, :ok?
    json_body = JSON.parse(last_response.body)

    refute_empty json_body
    assert_kind_of Hash, json_body
    assert_equal 0, json_body['items'].count

    uri = '/ka-ching/api/v1/test/lockings'
    req_data = { amount_cents_saldo_user_counted: 1501, action: :lock,
                 year: 2022, month: 11, day: 2 }
    post(uri, JSON.generate(req_data), header_content_type_json)

    assert_predicate last_response, :ok?

    get('/ka-ching/api/v1/test/lockings', { year: 2022, active: true })

    assert_predicate last_response, :ok?
    json_body = JSON.parse(last_response.body)

    refute_empty json_body
    assert_kind_of Hash, json_body
    assert_equal(1, json_body['items'].count)

    delete '/ka-ching/api/v1/test/lockings'

    assert_predicate last_response, :ok?
    json_body = JSON.parse(last_response.body)

    refute_empty json_body
    assert_kind_of Hash, json_body
    assert type_locking?(json_body)
    refute_operator(json_body, :[], 'active')
    assert_equal(0, DB::DATABASE_TENANT_TEST_CONN[:lockings].where(active: true).count)

    assert_equal(1, DB::DATABASE_TENANT_TEST_CONN[:audit_logs].count)
    audit_log = DB::DATABASE_TENANT_TEST_CONN[:audit_logs].first

    assert_equal('lockings', audit_log[:table_referenced])
    assert_operator audit_log, :[], :environment_snapshot
    assert_kind_of Sequel::Postgres::JSONBHash, audit_log[:environment_snapshot]
    assert type_locking?(audit_log[:environment_snapshot])
    assert_operator audit_log, :[], :log_entry
    assert_kind_of Sequel::Postgres::JSONBHash, audit_log[:log_entry]
    assert type_locking?(audit_log[:log_entry])
    assert_operator audit_log, :[], :created_at
    assert_operator audit_log, :[], :updated_at

    get('/ka-ching/api/v1/test/auditlogs', { year: Date.today.year })

    assert_predicate last_response, :ok?
    json_body = JSON.parse(last_response.body)

    refute_empty json_body
    assert_kind_of Hash, json_body
    assert_kind_of Array, json_body['audit_logs']

    audit_log = json_body['audit_logs'].first

    assert_equal(%w[id
                    table_referenced
                    environment_snapshot
                    log_entry created_at
                    updated_at], audit_log.keys)

    get '/ka-ching/api/v1/test/auditlogs', { year: Date.today.year, month: Date.today.month }

    assert_predicate last_response, :ok?
    json_body = JSON.parse(last_response.body)

    refute_empty json_body
    assert_kind_of Hash, json_body
    assert_kind_of Array, json_body['audit_logs']

    audit_log = json_body['audit_logs'].first

    assert_kind_of Array, json_body['audit_logs']

    assert_equal(%w[id
                    table_referenced
                    environment_snapshot
                    log_entry
                    created_at
                    updated_at].sort, audit_log.keys.sort)

    get '/ka-ching/api/v1/test/auditlogs', { year: Date.today.year, month: Date.today.month, day: Date.today.day }

    assert_predicate last_response, :ok?
    json_body = JSON.parse(last_response.body)

    refute_empty json_body
    assert_kind_of Hash, json_body
    assert_kind_of Array, json_body['audit_logs']
    audit_log = json_body['audit_logs'].first

    assert_equal(%w[id
                    table_referenced
                    environment_snapshot
                    log_entry created_at
                    updated_at], audit_log.keys)
  end
end
