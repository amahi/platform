class WebappAliasObserver < ActiveRecord::Observer

  def after_save(webapp_alias)
    save_webapp(webapp_alias)
  end

  def after_destroy(webapp_alias)
    save_webapp(webapp_alias)
  end

  private

	# save the webapp so that it picks up the server aliases
	def save_webapp(webapp_alias)
		webapp_alias.webapp && webapp_alias.webapp.save
	end
end
