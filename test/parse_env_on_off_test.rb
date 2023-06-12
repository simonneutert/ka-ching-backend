# frozen_string_literal: true

require 'test_helper'

class TestParseOnOff < MiniTest::Test
  def test_parse_on_off
    # Test all valid ON values
    assert parse_on_off('true')
    assert parse_on_off('on')
    assert parse_on_off('yes')
    assert parse_on_off('1')
    assert parse_on_off('enabled')
    assert parse_on_off('enable')
    assert parse_on_off('active')
    assert parse_on_off('activated')
    # Test all valid OFF values
    refute parse_on_off('false')
    refute parse_on_off('off')
    refute parse_on_off('no')
    refute parse_on_off('0')
    refute parse_on_off('nil')
    refute parse_on_off('null')
    refute parse_on_off('none')
    refute parse_on_off('disabled')
    refute parse_on_off('disable')
    refute parse_on_off('inactive')
    refute parse_on_off('deactivated')
  end

  def test_parse_on_off_invalid
    assert_raises(ArgumentError) { parse_on_off('invalid') }
  end
end
