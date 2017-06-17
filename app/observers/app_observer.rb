class AppObserver < ActiveRecord::Observer

  def before_destroy(app)
    app.uninstall
  end

end
