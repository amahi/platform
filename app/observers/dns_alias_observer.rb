class DnsAliasObserver < ActiveRecord::Observer

  def after_create(dns_alias)
    restart
  end

  def after_destroy(dns_alias)
    restart
  end

  def after_save(dns_alias)
    restart
  end

  protected
  def restart
		# FIXME - only do named
		system "hda-ctl-hup"
	end

end
