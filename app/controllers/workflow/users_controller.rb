class Workflow::UsersController < WorkflowController
  respond_to :html
  
  before_filter(:except => [:edit, :update]) {current_user.can_edit_users!}
  
  def index
    respond_with :workflow, @users = User.all
  end
  
  def new
    @authors = Author.open_authors.sort_by {|a| a.name.downcase }
    respond_with :workflow, @user = User.new
  end
  
  def create
    @authors = Author.open_authors.sort_by {|a| a.name.downcase }
    @user = User.new(
      :email => params[:email],
      :is_admin => params[:is_admin],
      :author => (Author.find(params[:author_id]) unless params[:author_id].empty?)
    )
    @password = @user.reset_password
    if @user.save
      render :action => "reset"
    else
      render :action => "new"
    end
  end
  
  def reset
    @user = User.find params[:id]
    @password = @user.reset_password
    @user.save!
  end
  
  def edit
    unless current_user.id == params[:id].to_i
      current_user.can_edit_users!
    end
    @user = User.find params[:id]
    if current_user.can_edit_users?
      @authors = Author.open_authors
      @authors << @user.author if @user.author
    end
    respond_with :workflow, @user
  end
  
  def update
    unless current_user.id == params[:id].to_i
      current_user.can_edit_users!
    end
    @user = User.find params[:id]
    @user.email = params[:user][:email]
    if params[:author_id]
      if params[:author_id].empty?
        @user.author = nil
      else
        @user.author = Author.find params[:author_id] 
      end
    end
    if current_user.is_admin
      @user.is_admin = params[:user][:is_admin]
    end
    if current_user == @user and not params[:password].strip.empty?
      @user.attributes = {:password => params[:password],
        :password_confirmation => params[:password_confirmation]}
    end
    @user.save
    
    respond_with :workflow, @user,
      :location => (current_user.can_edit_users? ? [:workflow, :users] : :workflow)
  end
end