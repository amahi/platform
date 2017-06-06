class DnsAliasParameters < ActionParameter::Base
  def permit
    params.require(:dns_alias).permit(:name, :address)
  end
end
