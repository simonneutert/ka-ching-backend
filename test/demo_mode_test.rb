# frozen_string_literal: true

require 'test_helper'

class DemoModeTest < Minitest::Test
  def test_enabled_demo_mode
    ENV['KACHING_DEMO_MODE'] = 'true'

    assert_predicate self, :enabled_demo_mode?
  end

  def test_disabled_demo_mode
    ENV['KACHING_DEMO_MODE'] = 'true'

    refute_predicate self, :disabled_demo_mode?
  end

  def test_enabled_demo_mode_off
    ENV['KACHING_DEMO_MODE'] = 'false'

    refute_predicate self, :enabled_demo_mode?
  end

  def test_production_protection_enabled
    ENV['RACK_ENV'] = 'production'
    ENV['KACHING_DEMO_MODE'] = 'false'

    assert_predicate self, :production_protection_enabled?
  end

  def test_production_protection_disabled
    ENV['RACK_ENV'] = 'production'
    ENV['KACHING_DEMO_MODE'] = 'true'

    refute_predicate self, :production_protection_enabled?
  end

  def test_production_protection_disabled_rack_env
    ENV['RACK_ENV'] = 'development'
    ENV['KACHING_DEMO_MODE'] = 'false'

    refute_predicate self, :production_protection_enabled?
  end

  def test_production_protection_disabled_rack_env_dev_demo_true
    ENV['RACK_ENV'] = 'development'
    ENV['KACHING_DEMO_MODE'] = 'true'

    refute_predicate self, :production_protection_enabled?
  end

  def test_production_protection_disabled_kaching_demo_mode
    ENV['RACK_ENV'] = 'production'
    ENV['KACHING_DEMO_MODE'] = nil

    assert_predicate self, :production_protection_enabled?
  end

  def test_production_protection_disabled_rack_env_kaching_demo_mode
    ENV['RACK_ENV'] = 'development'
    ENV['KACHING_DEMO_MODE'] = nil

    refute_predicate self, :production_protection_enabled?
  end
end
