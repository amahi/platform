module TabsHelper

  def tab_class(controller = nil)
    params[:controller] == controller ? 'preftabheaderActive' : 'preftabheaderInactive'
  end

  def subtab_class(action = nil)
    params[:action] == action ? 'prefsubtabheaderActive' : 'prefsubtabheaderInactive'
  end

  def debug_tab?
    advanced? || debug?
  end

  def advanced?
    Setting.get_by_name 'advanced'
  end

  def debug?
    #TODO
    false
  end
end


