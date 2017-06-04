class WebappObserver < ActiveRecord::Observer
  def before_create(webapp)
    # FIXME - a huuuuge amount of checks need to be
		# done here!
		webapp.create_dns_alias(:name => webapp.name)
		FileUtils.mkpath(File.join(path, "html"))
		FileUtils.mkpath(File.join(path, "logs"))
		webapp.write_conf_file
  end

  def after_save(webapp)
    # FIXME - check and change name, path, etc.
		webapp.write_conf_file
  end

  def after_destroy(webapp)
    c = Command.new
		c.submit("rm -f /etc/httpd/conf.d/#{webapp.fname}") unless webapp.fname.blank?
		c.submit("rm -rf #{path}")
		c.execute
		Platform.reload(:apache)
  end

  def before_validation_on_create(webapp)
    # create_unique_fname
    # ok, maybe not entirely unique, but this should
		# work fine - FIXME
    webapp.fname = "%4d-#{webapp.name}.conf" % (1000 + Webapp.count)
  end

end
