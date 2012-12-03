class UsersController < ApplicationController

  before_filter :admin_required
  before_filter :no_subtabs

  helper_method :can_i_toggle_admin?

  def index
    @page_title = t('users')
    get_all_users
  end

  def create
    @user = User.new(params[:user])
    @user.save
    get_all_users unless @user.errors.any?
  end

  def update
	  # This appears to be needed in some cases
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    render :json => {:id => @user.id}
  end

  def toggle_admin
    user = User.find params[:id]
    if can_i_toggle_admin?(user)
      user.admin = !user.admin
      user.save!
      @saved = true
    end
    render :json => { :status => @saved ? :ok : :not_acceptable }
  end

  def update_password
    @user = User.find(params[:id])
    @user.update_attributes(params[:user])
    errors = @user.errors.any?
    render :json => { :status => errors ? :not_acceptable : :ok, :message => errors ? '' : t('password_changed_successfully') }
  end

  def update_username
    @user = User.find(params[:id])
    @user.update_attributes(params[:user])
    render :json => { :status => @user.errors.any? ? :not_acceptable : :ok }
  end

  protected

  def can_i_toggle_admin?(user)
    current_user != user and !user.needs_auth?
  end

  def get_all_users
    @users = User.all_users
  end

end
