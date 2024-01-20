# frozen_string_literal: true

require 'test_helper'

class TestTenantsPagination < ApiIntegrationHelperTest
  include Rack::Test::Methods
  include Minitest::Hooks

  #
  # No bookings.
  #
  def test_tenant_database_queries
    # create the tenant database for sure
    post '/ka-ching/api/v1/admin', { tenant_account_id: 'test' }.to_json, header_content_type_json
    post '/ka-ching/api/v1/admin', { tenant_account_id: 'test2' }.to_json, header_content_type_json

    assert_predicate last_response, :ok?

    get '/ka-ching/api/v1/test2/saldo'

    assert_predicate last_response, :ok?

    get('/ka-ching/api/v1/tenants/all', { page: 1 }, header_content_type_json)

    assert_predicate last_response, :ok?

    json_body = JSON.parse(last_response.body)

    assert_equal(%w[current_page
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
                    items].sort, json_body.keys.sort)

    assert_equal(1, json_body['current_page'])
    assert_equal(1000, json_body['page_size'])
    assert_kind_of(Array, json_body['items'])
    refute_empty(json_body['items'])
    assert_equal(
      %w[
        id
        tenant_db_id
        active
        current_state
        next_state
        context
        created_at
        updated_at
      ].sort,
      json_body['items'][0].keys.sort
    )
  end
end
