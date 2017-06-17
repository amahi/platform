class UserParameters < ActionParameter::Base
  def permit
    if params[:user]
      user_params = params.require(:user).permit(:login, :name, :password, :password_confirmation, :admin, "public_key_#{params[:id]}")
      user_params.merge(params.permit(:id, :login, :name, :password, :password_confirmation, :admin, "public_key_#{params[:id]}"))
    else
      params.permit(:id, :login, :name, :password, :password_confirmation, :admin, "public_key_#{params[:id]}")
    end
  end
end
