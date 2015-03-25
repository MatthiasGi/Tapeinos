require 'test_helper'

class SettingsHelperTest < ActionView::TestCase

  test "Set setting" do
    SettingsHelper.set(:test, 'bla')
    SettingsHelper.set('test2', 'bla')
    assert_equal 'bla', SettingsHelper.get(:test)
    assert_equal 'bla', SettingsHelper.get(:test2)
  end

  test "Get default value" do
    assert_nil SettingsHelper.get(:test3)
    assert_equal 'bla', SettingsHelper.get(:test3, 'bla')
    SettingsHelper.set(:test, false)
    assert_not SettingsHelper.get(:test, true)
  end

end
