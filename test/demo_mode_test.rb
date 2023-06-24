# frozen_string_literal: true

require 'test_helper'

class DemoModeTest < Minitest::Test
  def test_production_protection_enabled
    ENV['RACK_ENV'] = 'production'
    ENV['KACHING_RESET_PROTECTION'] = 'false'

    refute_predicate self, :reset_protection_enabled?
  end

  def test_production_protection_disabled
    ENV['RACK_ENV'] = 'production'
    ENV['KACHING_RESET_PROTECTION'] = 'true'

    assert_predicate self, :reset_protection_enabled?
  end

  def test_production_protection_disabled_rack_env
    ENV['RACK_ENV'] = 'development'
    ENV['KACHING_RESET_PROTECTION'] = 'false'

    refute_predicate self, :reset_protection_enabled?
  end

  def test_production_protection_disabled_rack_env_dev_demo_true
    ENV['RACK_ENV'] = 'development'
    ENV['KACHING_RESET_PROTECTION'] = 'true'

    assert_predicate self, :reset_protection_enabled?
  end

  def test_production_protection_disabled_kaching_reset_protection
    ENV['RACK_ENV'] = 'production'
    ENV['KACHING_RESET_PROTECTION'] = nil

    refute_predicate self, :reset_protection_enabled?
  end

  def test_production_protection_disabled_rack_env_kaching_reset_protection
    ENV['RACK_ENV'] = 'development'
    ENV['KACHING_RESET_PROTECTION'] = nil

    refute_predicate self, :reset_protection_enabled?
  end
end
