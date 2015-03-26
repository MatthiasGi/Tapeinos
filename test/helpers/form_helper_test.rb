require 'test_helper'

class FormHelperTest < ActionView::TestCase
  include FormHelper

  test "chosen locales loaded properly" do
    locale = JSON.parse(chosen_locale)
    strings = [ :no_results_text, :placeholder_text_multiple, :placeholder_text_single ]
    strings.each do |string|
      assert_equal I18n.t("defaults.chosen.#{string}"), locale[string.to_s]
    end
  end

end
