# frozen_string_literal: true

require 'test_helper'

class RichErrorReturn < Minitest::Test
  def test_rich_error_return
    error = StandardError.new('test')
    error.define_singleton_method(:rich_error) { 'rich_error' }

    assert_equal({ status: error.class,
                   message: error.to_s,
                   error_object: error.rich_error },
                 rich_error_return(error, :rich_error))
  end
end
