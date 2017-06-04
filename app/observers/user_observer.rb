require 'command'
require 'platform'

class UserObserver < ActiveRecord::Observer

  def before_create(user)
    # FIXME: this is an issue with fedora 12 and usernames in lowercase
    # https://bugzilla.redhat.com/show_bug.cgi?id=550732
    # http://bugs.amahi.org/issues/show/392

    if Rails.env != "test" # we don't want this to execute in the test environment
      user.login = user.login.downcase
      return if User.system_user_exists? user.login
      pwd_option = user.password_option
      c = Command.new "useradd -m -g users -c \"#{user.name}\" #{pwd_option} \"#{user.login}\""
      # FIXME - we should use add_or_passwd_change_samba_user above! DRY
      unless user.password.nil? && user.password.blank?
        p = user.password
        c.submit("(echo '#{p}'; echo '#{p}') | pdbedit -d0 -t -a -u \"#{user.login}\"")
      end
      c.execute
    end
  end

  def after_create(user)
    if Rails.env != "test" # we don't want this to execute in the test environment
      Share.create_logon_script(user.login)
    end
  end

  def before_save(user)
    return unless User.system_user_exists? user.login
    pwd_option = user.password_option
    c = Command.new("usermod -c \"#{user.name}\" #{pwd_option} \"#{user.login}\"")
    c.execute
  end

  def after_save(user)
    if user.admin_changed?
      make_admin(user)
      Share.push_shares
    end
    if user.public_key_changed?
      update_pubkey(user)
    end
  end

  def before_destroy(user)
    c = Command.new("pdbedit -d0 -x -u \"#{user.login}\"")
    c.submit("userdel -r \"#{user.login}\"")
    c.execute
  end

  protected

	def update_pubkey(user)
		Platform.update_user_pubkey(user.login, user.public_key)
	end

	def make_admin(user)
		Platform.make_admin(user.login, user.admin?)
	end

end
