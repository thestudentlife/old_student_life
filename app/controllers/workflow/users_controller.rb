class Workflow::UsersController < ApplicationController
  before_filter :require_user
  before_filter(:except => [:edit, :update]) {current_staff_member.can_edit_users!}
  
  def index
    @users = StaffMember.all
  end
  
  def new
    @user = StaffMember.new
  end
  
  def create
    begin
      ActiveRecord::Base.transaction do
        @user = User.new(
          :email => params[:email]
        )
        @password = @user.reset_password
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
      render :action => "reset"
    end
  end
  
  def reset
    @user = User.find params[:id]
    @password = @user.reset_password
  end
  
  def edit
    unless current_staff_member.id == params[:id].to_i
      current_staff_member.can_edit_users!
    end
    @staff_member = StaffMember.find params[:id]
    @user = @staff_member.user
  end
  
  def update
    unless current_staff_member.can_edit_users or current_staff_member.id == params[:id].to_i
      current_staff_member.can_edit_users!
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
end