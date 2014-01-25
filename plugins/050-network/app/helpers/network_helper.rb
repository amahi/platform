module NetworkHelper
  def confirm_host_destroy_message(host)
    t('are_you_sure_host', :fixed_ip => host)
  end

  def confirm_dns_alias_destroy_message(dns_alias)
    t('are_you_sure_dns_alias', :dns_alias => dns_alias)
  end

  def alias_ip(dns_alias)
    addr = dns_alias.address
    net = Setting.get('net')
    if addr.nil? || addr.blank?
      # empty -- alias to the HDA
      net + '.' + Setting.get('self-address')
    elsif addr =~ /\A\d+\z/
      # just a number, same network
      net + '.' + addr
    else
      addr
    end
  end

  def dns_select_options
    %w(opendns google custom opennic).map { |dns_name| [dns_name, t("dns_#{dns_name}")] }
  end

end
