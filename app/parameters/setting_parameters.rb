class SettingParameters < ActionParameter::Base
  def permit
    params.require(:setting).permit(:name, :value, :kind)
  end
end
