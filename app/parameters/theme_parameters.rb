class ThemeParameters < ActionParameter::Base
  def permit
    params.require(:theme).permit(:name, :css)
  end
end
