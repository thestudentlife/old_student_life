require 'test_helper'

class WorkflowControllerTest < ActionController::TestCase
  setup :activate_authlogic

  test "should require login" do
    get :index
    assert_redirected_to workflow_login_path
  end
  test "should get index" do
    UserSession.create Factory.create(:user)
    get :index
    assert_response :success
  end
end
