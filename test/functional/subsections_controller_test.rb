require 'test_helper'

class SubsectionsControllerTest < ActionController::TestCase
  setup do
    @subsection = subsections(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:subsections)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create subsection" do
    assert_difference('Subsection.count') do
      post :create, :subsection => @subsection.attributes
    end

    assert_redirected_to subsection_path(assigns(:subsection))
  end

  test "should show subsection" do
    get :show, :id => @subsection.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @subsection.to_param
    assert_response :success
  end

  test "should update subsection" do
    put :update, :id => @subsection.to_param, :subsection => @subsection.attributes
    assert_redirected_to subsection_path(assigns(:subsection))
  end

  test "should destroy subsection" do
    assert_difference('Subsection.count', -1) do
      delete :destroy, :id => @subsection.to_param
    end

    assert_redirected_to subsections_path
  end
end
