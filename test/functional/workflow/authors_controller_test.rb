require 'test_helper'

class Workflow::AuthorsControllerTest < ActionController::TestCase
  setup do
    @workflow_author = workflow_authors(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:workflow_authors)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create workflow_author" do
    assert_difference('Workflow::Author.count') do
      post :create, :workflow_author => @workflow_author.attributes
    end

    assert_redirected_to workflow_author_path(assigns(:workflow_author))
  end

  test "should show workflow_author" do
    get :show, :id => @workflow_author.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @workflow_author.to_param
    assert_response :success
  end

  test "should update workflow_author" do
    put :update, :id => @workflow_author.to_param, :workflow_author => @workflow_author.attributes
    assert_redirected_to workflow_author_path(assigns(:workflow_author))
  end

  test "should destroy workflow_author" do
    assert_difference('Workflow::Author.count', -1) do
      delete :destroy, :id => @workflow_author.to_param
    end

    assert_redirected_to workflow_authors_path
  end
end
