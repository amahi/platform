class HostObserver < ActiveRecord::Observer

  def after_create(host)
    restart
  end

  def after_destroy(host)
    restart
  end

  def after_save(host)
    restart
  end

  protected
  def restart
		# FIXME - only do named
		system "hda-ctl-hup"
	end

end
