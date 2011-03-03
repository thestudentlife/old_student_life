require 'digest/sha1'

class User < ActiveRecord::Base
  validates_length_of :username, :within => 3..40
  validates_presence_of :username, :password
  validates_uniqueness_of :username
  
  attr_protected :id, :salt
  
  has_one :staff_member
  
  def self.random_string (len)
    #generate a random password consisting of strings and digits
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    newpass = ""
    1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
    return newpass
  end
  
  def self.encrypt (pass, salt)
    salt + "$" + Digest::SHA1.hexdigest (pass + salt)
  end
  
  def self.authenticate (username, password)
    user = find :first, :conditions => ["username = ?", username]
    return nil if user.nil?
    salt = user.password.split("$")[0]
    return user if User.encrypt (password, salt) == user.password
    nil
  end
  
  def password
    hashed_password
  end
  def password=(pass)
    salt = User.random_string(10)
    self.hashed_password = User.encrypt(pass, salt)
  end
end
