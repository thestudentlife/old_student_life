require 'test_helper'

class WorkflowControllerTest < ActionController::TestCase
  
  setup :activate_authlogic
  requires_login :index, :get
  
  test "should get index" do
    workflow_login!
    get :index
    assert_response :success
  end
  
end
