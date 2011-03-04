class User < ActiveRecord::Base
  acts_as_authentic
  
  has_one :staff_member
  
  def self.dummy_password
    "somelongdummypassword"
  end
  
  def reset_password
    random_string(8).tap do |pass|
      update_attributes!(
        :password => pass,
        :password_confirmation => pass
      )
    end
  end
  
  def to_s
    self.email
  end
  
  private
  def random_string(len)
    #generate a random password consisting of strings and digits
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    newpass = ""
    1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
    return newpass
  end
end
