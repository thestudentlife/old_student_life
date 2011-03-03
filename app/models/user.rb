class User < ActiveRecord::Base
  acts_as_authentic
  
  has_one :staff_member
  
  def to_s
    self.email
  end
end
