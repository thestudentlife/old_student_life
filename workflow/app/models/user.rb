class User < ActiveRecord::Base
  class NotAuthorized < Exception; end
  
  acts_as_authentic
  
  has_one :author
  
  def self.dummy_password
    "somelongdummypassword"
  end
  
  def reset_password
    random_string(8).tap do |pass|
      self.attributes = {
        :password => pass,
        :password_confirmation => pass
      }
    end
  end
  
  def can_add_review? (article)
    article.open_review_slots.find { |slot| not slot.requires_admin? }
  end
  
  [
    :authors,
    :front_page,
    :issues,
    :sections,
    :users
  ].map{ |m|
    "can_edit_#{m}"
  }.each do |permission|
    define_method("#{permission}?") do 
      is_admin
    end
    define_method("#{permission}!") do
      send("#{permission}?") or raise NotAuthorized
    end
  end
  
  def to_s
    email
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
