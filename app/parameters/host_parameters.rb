class HostParameters < ActionParameter::Base
  def permit
    if params[:host]
      host_params = params.require(:host).permit(:name, :mac, :address)
      host_params.merge(params.permit(:name, :mac, :address, :id, :value))
    else
      params.permit(:id, :name, :mac, :address, :value)
    end
  end
end
