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

  test "date range" do
    date = Date.new(2015, 10, 8)
    tester = {
      incl_day: Date.new(2015, 10, 10),
      incl_month: Date.new(2015, 11, 12),
      incl_year: Date.new(2016, 10, 1)
    }

    tester.each do |key, value|
      range = date_range(date, value)
      str1 = I18n.l(date, format: key)
      str2 = I18n.l(value)
      assert_equal "#{str1} – #{str2}", range
    end
  end

  test "date range for nil" do
    date = Date.new(2015, 10, 8)
    range = date_range(date, nil)
    assert_equal I18n.l(date), range

    date = Date.new(2015, 10, 9)
    range = date_range(nil, date)
    assert_equal I18n.l(date), range

    range = date_range(nil, nil)
    assert_equal '', range
  end

  test "first = last date range" do
    date = Date.new(2015, 10, 8)
    range = date_range(date, date)
    assert_equal I18n.l(date), range
  end

  test "date locale" do
    date = DateTime.now
    assert_equal I18n.l(date), locale(date)
    assert_equal I18n.l(date, format: :long), locale(date, format: :long)
    assert_equal '', locale(nil)
  end

  test "percentage of enrolled servers" do
    plan = Plan.first
    servers = User.first.servers + [ servers(:heinz) ]
    assert plan.update(servers: servers)
    plan = Plan.find(plan.id)

    html = enrollement(plan)
    assert_select node(html), '.progress .progress-bar.empty', 0
    assert_select node(html), '.progress .progress-bar', plan.servers.count.to_s + ' / ' + Server.count.to_s
    percentage = 100 * servers.count / Server.count
    assert_match /width: #{percentage}%/, html
  end

  test "percentage of empty plan" do
    plan = plans(:easter)
    html = enrollement(plan)
    assert_select node(html), '.progress .progress-bar.empty', '0 / ' + Server.count.to_s
    assert_match /width: 0%/, html
  end

  test "test server-error-helper" do
    set_sidekiq = SettingsHelper.get(:sidekiq_up)
    set_redis = SettingsHelper.get(:redis_up)

    SettingsHelper.set(:sidekiq_up, false)
    # ( error-condition, message )
    html = server_error(:sidekiq_up, :sidekiq_down)
    assert_select node(html), '.alert.alert-danger'
    assert_match I18n.t('errors.sidekiq_down'), html

    SettingsHelper.set(:redis_up, true)
    html = server_error(:redis_up, :redis_down)
    assert_nil html

    SettingsHelper.set(:sidekiq_up, set_sidekiq)
    SettingsHelper.set(:redis_up, set_redis)
  end

end
