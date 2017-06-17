class WebappParameters < ActionParameter::Base
  def permit
    params.require(:webapp).permit(:name, :fname, :path, :deletable, :custom_options, :kind)
  end
end
