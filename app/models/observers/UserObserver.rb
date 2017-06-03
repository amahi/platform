class UserObserver < ActiveRecord::Observer

  def before_create(user)
    # FIXME: this is an issue with fedora 12 and usernames in lowercase
    # https://bugzilla.redhat.com/show_bug.cgi?id=550732
    # http://bugs.amahi.org/issues/show/392
    user.login = user.login.downcase
    return if User.system_user_exists? user.login
    pwd_option = password_option()
    # FIXME: use a different (programmable) group
    c = Command.new "useradd -m -g users -c \"#{user.name}\" #{pwd_option} \"#{user.login}\""
    # FIXME - we should use add_or_passwd_change_samba_user above! DRY
    unless user.password.nil? && user.password.blank?
      p = user.password
      c.submit("(echo '#{p}'; echo '#{p}') | pdbedit -d0 -t -a -u \"#{user.login}\"")
    end
    c.execute
  end

  def after_create(user)
    Share.create_logon_script(user.login)
  end

  def before_save(user)
    return unless User.system_user_exists? user.login
    pwd_option = password_option()
    c = Command.new("usermod -c \"#{user.name}\" #{pwd_option} \"#{user.login}\"")
    c.execute
  end

  def after_save(user)
    if admin_changed?
      make_admin
      Share.push_shares
    end
    if public_key_changed?
      update_pubkey
    end
  end

  def before_destroy(user)
    c = Command.new("pdbedit -d0 -x -u \"#{user.login}\"")
    c.submit("userdel -r \"#{user.login}\"")
    c.execute
  end

end
