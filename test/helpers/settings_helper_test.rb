require 'test_helper'

class FormHelperTest < ActionView::TestCase

  def setup
    @file = 'config/settings.test.yml'
    File.delete(@file) if File.exists?(@file)
  end

  test "Loading settings" do
    config = { test: 'bla' }
    File.open(@file, 'w') do |h|
      h.write config.to_yaml
    end
    assert_equal 'bla', SettingsHelper.get(:test)
  end

  test "Loading settings if file not existant" do
    assert_not SettingsHelper.get(:test)
  end

  test "Get setting" do
    config = { test: 'bla' }
    File.open(@file, 'w') do |h|
      h.write config.to_yaml
    end
    assert_equal 'bla', SettingsHelper.get(:test)
    assert_equal 'bla', SettingsHelper.get('test')
  end

  test "Set setting" do
    SettingsHelper.set(:test, 'bla')
    SettingsHelper.set('test2', 'bla')
    assert_equal 'bla', SettingsHelper.get(:test)
    assert_equal 'bla', SettingsHelper.get(:test2)
  end

  test "Get default value" do
    assert_nil SettingsHelper.get(:test)
    assert_equal 'bla', SettingsHelper.get(:test, 'bla')
    SettingsHelper.set(:test, false)
    assert_not SettingsHelper.get(:test, true)
  end

end
