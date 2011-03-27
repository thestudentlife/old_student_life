require 'test_helper'

class Workflow::AuthorsControllerTest < ActionController::TestCase
  
  setup do
    activate_authlogic
    @author = Factory.create(:author)
  end
  
  requires_login :index, :get
  requires_login :new, :get
  requires_login :show, :get, :id => 4
  requires_login :edit, :get, :id => 4
  requires_login :create, :post
  requires_login :update, :put, :id => 4
  requires_login :destroy, :delete, :id => 4
  
  test "should get index" do
    workflow_login!
    get :index
    assert_response :success
  end
  
  test "should get new" do
    workflow_login!
    get :new
    assert_response :success
  end
  
  test "should show author" do
    workflow_login!
    get :show, :id => @author.id
    assert_response :success
  end
  
  test "should edit author" do
    workflow_login!
    get :edit, :id => @author.id
    assert_response :success
  end
  
  test "should create author" do
    workflow_login!
    assert_difference('Author.count') do
      post :create, :author => Factory.attributes_for(:author)
    end
    # assert_redirected_to :action => :show, :id => assigns[:author].to_param
    assert_redirected_to :action => :index
  end
  
  test "should update author" do
    workflow_login!
    put :update, :id => @author.to_param, :author => @author.attributes
    # assert_redirected_to :action => :show, :id => assigns[:author].to_param
    assert_redirected_to :action => :index
  end
  
  test "should destroy author" do
    workflow_login!
    assert_difference('Author.count', -1) do
      delete :destroy, :id => @author.to_param
    end
    assert_redirected_to :action => :index
  end

end