module AppsHelper

  def short_desc(app)
    desc = app.description ? app.description.gsub(/<[^>]+>/, '') : t('no_description_supplied')
    desc = truncate(strip_tags(desc), :length => 70, :omission => '&nbsp;...') if desc.length > 70
    desc.html_safe
  end

  def name_with_warning(app)
    app.testing? ? "#{app.name}<sup>*</sup>".html_safe : app.name
  end

  def image_for_app(app)
    image_tag(app.screenshot_url, :class => 'app-screenshot', :align => 'left', :title => "#{app.name} screenshot").html_safe
  end

  def display_app?
    request.xhr?
  end

  def display_style
    request.xhr? ? '' : 'display: none;'
  end

end
