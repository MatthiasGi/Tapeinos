require 'test_helper'

class DesignHelperTest < ActionView::TestCase
  include DesignHelper

  def setup
    @virtual_path = "test"
  end

  test "page header" do
    title = SecureRandom.hex
    remark = SecureRandom.hex

    doc = node(page_header(title))
    assert_select doc, '.page-header > h1', title
    assert_select doc, '.page-header small', false

    doc = node(page_header(title, remark))
    assert_select doc, '.page-header > h1 > small', remark
  end

  test "single flash-message" do
    doc = node(flash_message('test'))
    assert_select doc, '.alert.alert-info', false

    flash[:test] = true
    doc = node(flash_message('test'))
    assert_select doc, '.alert.alert-info', 'Test'

    doc = node(flash_message('test', context: :danger))
    assert_select doc, '.alert.alert-danger', 'Test'

    doc = node(flash_message('test', context: :success, text: 'Blabla'))
    assert_select doc, '.alert.alert-success', 'Blabla'

    doc = node(flash_message('test', text: 'Blabla'))
    assert_select doc, '.alert.alert-info', 'Blabla'
  end

  test "array of flash-messages" do
    flash[:test1] = flash[:test2] = flash[:test3] = flash[:test4] = true
    doc = node(flash_messages(:test1, [:test2, context: :danger], [:test3, context: :success, text: 'Blabla'], [:test4, text: 'Blabla'], [:test5, context: :warning]))

    assert_select doc, '.alert.alert-info', 'Test1'
    assert_select doc, '.alert.alert-danger', 'Test2'
    assert_select doc, '.alert.alert-success', 'Blabla'
    assert_select doc, '.alert.alert-info', 'Blabla'
    assert_select doc, '.alert.alert-warning', false
  end

  test "rank-icons" do
    icons = { novice: :pawn, disciple: :bishop, veteran: :tower, master: :king }
    icons.each do |key, value|
      doc = node(rank_icon(key))
      assert_select doc, ".glyphicon.glyphicon-#{value}"
    end
  end

  test "state-icons" do
    icons = { draft: :edit, sent: :check }
    icons.each do |key, value|
      doc = node(state_icon(key))
      assert_select doc, ".glyphicon.glyphicon-#{value}"
    end
  end

end
