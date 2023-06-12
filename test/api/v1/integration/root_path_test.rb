# frozen_string_literal: true

require 'test_helper'

class TestRootPath < ApiIntegrationHelperTest
  include Rack::Test::Methods
  include Minitest::Hooks

  def test_root
    get '/ka-ching/api/v1'

    assert_predicate last_response, :ok?

    json_body = JSON.parse(last_response.body)

    assert_equal('V1', json_body['api'])
    assert_equal('success', json_body['health'])
  end
end
