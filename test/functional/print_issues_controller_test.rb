require 'test_helper'

class PrintIssuesControllerTest < ActionController::TestCase
  setup do
    @print_issue = print_issues(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:print_issues)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create print_issue" do
    assert_difference('PrintIssue.count') do
      post :create, :print_issue => @print_issue.attributes
    end

    assert_redirected_to print_issue_path(assigns(:print_issue))
  end

  test "should show print_issue" do
    get :show, :id => @print_issue.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @print_issue.to_param
    assert_response :success
  end

  test "should update print_issue" do
    put :update, :id => @print_issue.to_param, :print_issue => @print_issue.attributes
    assert_redirected_to print_issue_path(assigns(:print_issue))
  end

  test "should destroy print_issue" do
    assert_difference('PrintIssue.count', -1) do
      delete :destroy, :id => @print_issue.to_param
    end

    assert_redirected_to print_issues_path
  end
end
