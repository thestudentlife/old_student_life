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
  
  def available_workflow_statuses
    if is_admin
      return WorkflowStatus.all
    else
      return WorkflowStatus.where(:requires_admin => false)
    end
  end
  
  def can_override_workflow?
    is_admin
  end
  
  def can_publish_revision? (revision)
    revision.can_be_published_by self
  end
  def can_publish_revision! (revision)
    can_publish_revision?(revision) or raise NotAuthorized
  end
  
  [
    :headlines,
    :issues,
    :sections,
    :workflow_statuses,
    :users,
    :authors
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
