class PluginParameters < ActionParameter::Base
  def permit
    params.require(:plugin).permit(:name, :path)
  end
end
