class ServerParameters < ActionParameter::Base
  def permit
    if params[:server]
      server_params = params.require(:server).permit(:name, :pidfile, :comment)
      server_params.merge(params.permit(:name, :pidfile, :comment, :id))
    else
      params.permit(:name, :pidfile, :comment, :id)
    end
  end
end
