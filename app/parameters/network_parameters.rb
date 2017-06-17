class NetworkParameters < ActionParameter::Base
  def permit
    params.permit(:setting_dns, :dns_ip_1, :dns_ip_2, :lease_time, :gateway, :id, :dyn_lo, :dyn_hi)
  end
end
