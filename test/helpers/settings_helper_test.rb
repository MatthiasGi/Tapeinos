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

  test "Get hashes" do
    SettingsHelper.set(:blubb, 'bla')
    SettingsHelper.set(:testing, 5)
    hash = SettingsHelper.getHash
    assert_equal 'bla', hash[:blubb]
    assert_equal 5, hash[:testing]
  end

  test "Set hashes" do
    SettingsHelper.setHash({ 'test42' => 42, testenen: 35 })
    assert_equal 42, SettingsHelper.get('test42')
    assert_equal 35, SettingsHelper.get(:testenen)
  end

  test "Feedback only if something changed" do
    SettingsHelper.set(:changed, nil)
    SettingsHelper.set(:testing, nil)
    assert SettingsHelper.set(:changed, '123')
    assert_not SettingsHelper.set(:changed, '123')
    assert SettingsHelper.set(:changed, '1234')

    assert_not SettingsHelper.setHash({ changed: '1234' })
    assert SettingsHelper.setHash({ changed: '123' })

    assert SettingsHelper.setHash({ changed: '123', testing: 'changed' })
    assert_not SettingsHelper.setHash({ changed: '123', testing: 'changed' })
    assert SettingsHelper.setHash({ changed: '1234', testing: 'changed' })
  end

end
