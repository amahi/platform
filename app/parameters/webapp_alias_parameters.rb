class WebappAliasParameters < ActionParameter::Base
  def permit
    params.require(:webapp_alias).permit(:name, :webapp_id)
  end
end
