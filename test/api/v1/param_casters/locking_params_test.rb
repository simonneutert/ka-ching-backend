# frozen_string_literal: true

require 'test_helper'

class TestLockingParams < ApiIntegrationHelperTest
  include Rack::Test::Methods
  include Minitest::Hooks

  def setup
    @locking_param_caster = Api::V1::Locking::ParamsCaster
  end

  def test_missing_key_in_params
    error = assert_raises(KeyError) do
      @locking_param_caster.new(
        { 'action' => 'deposit' }
      )
    end

    assert_includes(error.message, 'amount_cents_saldo_user_counted')
  end

  def test_value_not_castable_from_params
    error = assert_raises(ArgumentError) do
      @locking_param_caster.new(
        { 'action' => 'lock',
          'amount_cents_saldo_user_counted' => 'a lot of money' }
      )
    end

    assert_includes(error.message, 'invalid value for Integer')
  end

  def test_locking_from_params_successful
    locking = @locking_param_caster.new(
      {
        'action' => 'lock',
        'amount_cents_saldo_user_counted' => 1000,
        'year' => 2022,
        'month' => 10,
        'day' => 11,
        'context' => {
          'message' => 'I am a locking for account 123'
        }
      }
    )

    assert_equal('lock', locking.action)
    assert_equal(1000, locking.amount_cents_saldo_user_counted)
    assert_equal(2022, locking.year)
    assert_equal(10, locking.month)
    assert_equal(11, locking.day)
    assert_kind_of(Hash, locking.context)

    assert_empty(%i[@action @amount_cents_saldo_user_counted @year @month @day @context] - locking.instance_variables)
  end

  def test_locking_from_params_context_is_optional
    locking = @locking_param_caster.new(
      {
        'action' => 'lock',
        'amount_cents_saldo_user_counted' => 1000,
        'year' => 2022,
        'month' => 10,
        'day' => 11
      }
    )

    assert_equal('lock', locking.action)
    assert_equal(1000, locking.amount_cents_saldo_user_counted)
    assert_equal(2022, locking.year)
    assert_equal(10, locking.month)
    assert_equal(11, locking.day)
    assert_empty(locking.context)
  end
end
