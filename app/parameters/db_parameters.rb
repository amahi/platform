class DbParameters < ActionParameter::Base
  def permit
    params.require(:db).permit(:name)
  end
end
