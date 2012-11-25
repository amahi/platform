module UsersHelper

  def user_icon_class(user)
    user_icon = ""
    user_icon = "user_admin" if user.admin
    user_icon = "user_warn" if user.needs_auth?
    user_icon
  end

  def confirm_user_destroy_message(login)
    [t('are_you_sure_user', :user => login),
     t('this_users_files_deleted'), "", t('there_is_no_undo'), ""].join("\n").html_safe
  end

  def user_formatted_date(date)
    date = date.localtime
    "#{date.to_formatted_s(:short)} (#{time_ago_in_words(date)})"
  rescue
    '-'
  end




end
