ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'authlogic/test_case'

class ActiveSupport::TestCase
  # Add helper methods to be used by all tests here...
  
  def workflow_login!
    UserSession.create Factory.create(:user)
  end
  
  def self.requires_login (action, method, *args)
    test "should require login on action #{action}" do
      send method, action, *args
      assert_redirected_to workflow_login_path
    end
  end
  
end