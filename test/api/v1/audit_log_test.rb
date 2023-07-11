# frozen_string_literal: true

require 'test_helper'

# TODO: write unit test for auditlog logic logging an object and a complex/hash of objects as result_state

class TestAuditLoggable < ApiIntegrationHelperTest
  include Rack::Test::Methods
  include Minitest::Hooks

  def setup
    @tenant_db_name = 'kaching_tenant_test'
    @table_name = :lockings
    @before_state = { 'active' => true }
    @result_state = { 'active' => false }
  end

  #
  # helper method for db connection
  #
  # @return [Sequel::Database] db connection
  #
  def db
    DB.db_connection(@tenant_db_name)
  end

  def test_create_audit_log_with_single_object_as_result_state
    db.transaction do
      db[:audit_logs].insert(table_referenced: @table_name.to_s,
                             environment_snapshot: @before_state.to_json,
                             log_entry: @result_state.to_json)
    end

    assert_equal(1, db[:audit_logs].count)
    assert_equal(@table_name.to_s, db[:audit_logs].first[:table_referenced])
    assert_equal(@before_state, JSON.parse(db[:audit_logs].first[:environment_snapshot]))
    assert_equal(@result_state, JSON.parse(db[:audit_logs].first[:log_entry]))
  end

  def test_create_audit_log_with_complex_hash_of_objects_as_result_state
    @result_state = { 'object1' => { 'active' => false },
                      'object2' => { 'active' => true } }

    db.transaction do
      db[:audit_logs].insert(table_referenced: @table_name.to_s,
                             environment_snapshot: @before_state.to_json,
                             log_entry: @result_state.to_json)
    end

    assert_equal(1, db[:audit_logs].count)
    assert_equal(@table_name.to_s, db[:audit_logs].first[:table_referenced])
    assert_equal(@before_state, JSON.parse(db[:audit_logs].first[:environment_snapshot]))
    assert_equal(@result_state, JSON.parse(db[:audit_logs].first[:log_entry]))
  end
end
