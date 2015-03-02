require 'test_helper'

class ButtonHelperTest < ActionView::TestCase
  include ButtonHelper

  test "basic button link" do
    doc = node(btn_link_to 'Test', 'google.de')
    assert_select doc, 'a.btn.btn-default[href="google.de"]', 'Test'
  end

  test "button link contexts" do
    contexts = [:success, :primary, :danger, :info, :warning, :default, :link]
    contexts.each do |context|
      doc = node(btn_link_to 'Test', '#', context: context)
      assert_select doc, "a.btn.btn-#{context}", 'Test'
    end
  end

  test "button link sizes" do
    sizes = [:xs, :sm, :lg]
    sizes.each do |size|
      doc = node(btn_link_to 'Test', '#', size: size)
      assert_select doc, "a.btn.btn-#{size}", 'Test'
    end
  end

  test "button link block layout" do
    doc = node(btn_link_to 'Test', '#', layout: :block)
    assert_select doc, "a.btn.btn-default.btn-block", 'Test'
  end

  test "button link icon" do
    doc = node(btn_link_to 'Test', '#', icon: :user)
    assert_select doc, "a.btn.btn-default .glyphicon.glyphicon-user"
  end

end
