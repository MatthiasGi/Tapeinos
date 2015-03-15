require 'test_helper'

class Admin::PlansControllerTest < ActionController::TestCase

  def setup
    user = users(:admin)
    session[:user_id] = user.id
    session[:server_id] = user.servers.first.id
  end

  test "index shows all plans" do
    get :index
    assert_response :success
    assert_template :index
    plans = Plan.all
    expected = plans.reject(&:first_date) + plans.select(&:first_date).sort_by(&:first_date)
    assert_equal expected, assigns(:plans)
  end

  test "show invalid plan" do
    get :show, { id: 1 }
    assert_redirected_to admin_plans_path
  end

  test "show valid plan" do
    plan = plans(:easter)
    get :show, { id: plan.id }
    assert_response :success
    assert_template :show
    assert_equal plan, assigns(:plan)
  end

  test "edit invalid plan" do
    get :edit, { id: 1 }
    assert_redirected_to admin_plans_path
  end

  test "edit valid plan" do
    plan = plans(:easter)
    get :edit, { id: plan.id }
    assert_response :success
    assert_template :edit
    assert_equal plan, assigns(:plan)
  end

  test "update with wrong parameters" do
    plan = plans(:easter)
    patch :update, { id: plan.id, plan: { title: '' }}
    assert_response :success
    assert_template :edit
    assert_equal plan, assigns(:plan)
    assert_select '.plan_title.has-error .help-block'
  end

  test "update valid parameters" do
    old = plans(:easter)
    old_ev = old.events.first
    patch :update, { id: old.id, plan: { title: 'TEST', remark: 'blabla', events_attributes: { id: old_ev.id, date: 1.day.ago, title: 'testen' }}}
    new = Plan.find(old.id)
    assert_equal 'TEST', new.title
    assert_equal 'blabla', new.remark
    new_ev = Event.find(old_ev.id)
    assert_equal 1.day.ago.to_date, new_ev.date.to_date
    assert_equal 'testen', new_ev.title
    assert_redirected_to admin_plan_path(old)
  end

  test "remove an event" do
    plan = plans(:easter)
    id = plan.events.first.id
    assert_difference 'Plan.find(plan.id).events.count', -1 do
      patch :update, { id: plan.id, plan: { events_attributes: { id: id, _destroy: 1 }}}
    end
    assert_not Event.find_by(id: id)
  end

  test "deleting plan" do
    plan = plans(:easter)
    delete :destroy, { id: plan.id }
    assert_redirected_to admin_plans_path
    assert_not Plan.find_by(id: plan.id)
  end

  test "deleting invalid plan" do
    delete :destroy, { id: 1 }
    assert_redirected_to admin_plans_path
  end

  test "show new plan form" do
    get :new
    assert_response :success
    assert_template :new
    assert assigns(:plan)
  end

  test "create plan" do
    assert_difference 'Plan.all.count', +1 do
      assert_difference 'Event.all.count', +2 do
        post :create, { plan: { title: 'Test', events_attributes: [{ date: 2.days.ago }, { date: 1.day.ago }]}}
      end
    end
    assert_redirected_to admin_plan_path(Plan.all.last)
  end

  test "create plan with error" do
    assert_no_difference 'Plan.all.count' do
      assert_no_difference 'Event.all.count' do
        post :create, { plan: { title: '', events_attributes: [{ date: 2.days.ago, needed: 1 }, { date: 1.day.ago, needed: 1 }]}}
      end
    end
    assert_response :success
    assert_template :new
    assert_select '.plan_title.has-error .help-block'
  end

end
