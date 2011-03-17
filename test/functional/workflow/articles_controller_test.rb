require 'test_helper'

class Workflow::ArticlesControllerTest < ActionController::TestCase
  
  setup do
    activate_authlogic
    @article = Factory.create(:article)
  end
  
  requires_login :show, :get, :id => 4
  requires_login :edit, :get, :id => 4
  requires_login :update, :put, :id => 4
  
  test "should show article" do
    workflow_login!
    get :show, :id => @article.id
    assert_response :success
  end
  
  test "should edit article" do
    workflow_login!
    get :edit, :id => @article.id
    assert_response :success
  end
  
  test "should update article" do
    workflow_login!
    put :update, :id => @article.to_param, :article => @article.attributes
    assert_redirected_to :action => :show, :id => @article.id
  end

end