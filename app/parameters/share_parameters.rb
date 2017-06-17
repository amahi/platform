class ShareParameters < ActionParameter::Base
  def permit
    if params[:share]
      share_params = params.require(:share).permit(:name,:rdonly, :visible, :tags, :extras, :value, :path)
      share_params.merge(params.permit(:id, :name, :path, :rdonly, :visible, :tags, :extras, :value, :user_id, :path))
    else
      params.permit(:id, :name, :path, :rdonly, :visible, :tags, :extras, :value, :user_id, :path)
    end
  end
end
