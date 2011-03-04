class Workflow::UsersController < ApplicationController
  before_filter :require_user
  before_filter :require_privileges, :except => [:edit, :update]
  
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
    unless current_staff_member.can_edit_users or current_staff_member.id = params[:id]
      raise ActionController::RoutingError.new('Not Found')
    end
    @staff_member = StaffMember.find params[:id]
    @user = @staff_member.user
  end
  
  def update
    unless current_staff_member.can_edit_users or current_staff_member.id = params[:id]
      raise ActionController::RoutingError.new('Not Found')
    end
    @staff_member = StaffMember.find params[:id]
    @user = @staff_member.user
    begin
      ActiveRecord::Base.transaction do
        @user.email = params[:user][:email]
        @user.save!
        
        @staff_member.is_admin = params[:user][:is_admin]
        @staff_member.save!
        
        if current_user == @user and not params[:password].empty?
          @user.update_attributes!(
            :password => params[:password],
            :password_confirmation => params[:password_confirmation]
          )
        end
      end
    rescue
      render :action => :edit
    else
      flash[:notice] = "Account updated!"
      if current_staff_member.can_edit_users
        redirect_to workflow_users_path
      else
        redirect_to workflow_path
      end
    end
  end
  
  private
  def require_privileges
    unless current_user.staff_member.can_edit_users
      raise ActionController::RoutingError.new('Not Found')
    end
  end
  
  def random_string(len)
    #generate a random password consisting of strings and digits
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    newpass = ""
    1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
    return newpass
  end
end