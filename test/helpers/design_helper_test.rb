require 'test_helper'

class DesignHelperTest < ActionView::TestCase
  include DesignHelper

  test "page header" do
    title = SecureRandom.hex
    remark = SecureRandom.hex

    doc = node(page_header(title))
    assert_select doc, '.page-header > h1', title
    assert_select doc, '.page-header small', false

    doc = node(page_header(title, remark))
    assert_select doc, '.page-header > h1 > small', remark
  end

end
