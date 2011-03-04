class Workflow::UsersController < ApplicationController
  before_filter :require_user, :only => [:show, :edit, :update]
  
  def index
    @users = StaffMember.all
  end
  
  def new
    @user = StaffMember.new
  end
  
  def create
    @password = random_string(8)
    begin
      ActiveRecord::Base.transaction do
        @user = User.new(
          :email => params[:email],
          :password => @password,
          :password_confirmation => @password
        )
        @user.save!
    
        @staff_member = StaffMember.create(
          :user => @user,
          :is_admin => params[:is_admin]
        )
        @staff_member.save!
      end
    rescue
      render :action => "new"
    else
      redirect_to(
        workflow_users_path,
        :flash => {
          :notice => "Account registered!",
          :password => @password
        }
      )
    end
  end
  
  def edit
    @user = StaffMember.find params[:id]
  end
  
  def update
    @user = StaffMember.find params[:id]
    @auth_user = @user.user
    begin
      ActiveRecord::Base.transaction do
        @auth_user.email = params[:user][:email]
        @auth_user.save!
        
        @user.is_admin = params[:user][:is_admin]
        @user.save!
      end
    rescue
      render :action => :edit
    else
      flash[:notice] = "Account updated!"
      redirect_to workflow_users_path
    end
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