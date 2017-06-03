class ShareObserver < ActiveRecord::Observer

  def before_save(share)
    share.tags = share.tags.split(/\s*,\s*|\s+/).reject {|s| s.empty? }.join(', ').downcase if share.tags_changed?
    return unless share.path_changed?
    return if share.path.nil? or share.path.blank?
    user = User.admins.first.login
    c = Command.new
    c.submit("rmdir \"#{share.path_was}\"") unless share.path_was.blank?
    c.submit("mkdir -p \"#{share.path}\"")
    c.submit("chown #{user}:users \"#{share.path}\"")
    c.submit("chmod g+w \"#{share.path}\"")
    c.execute
  end

  def before_destroy(share)
    c = Command.new("rmdir --ignore-fail-on-non-empty \"#{share.path}\"")
    c.execute
  end

  def after_save(share)
    if share.guest_writeable_changed?
      share.guest_writeable ? share.make_guest_writeable : share.make_guest_non_writeable
    end
    if everyone
      users = User.all
      share.users_with_share_access = users
      share.users_with_write_access = users
    end
    Share.push_shares
    # Greyhole.save_conf_file(DiskPoolPartition.all, Share.in_disk_pool)
  end

  def after_destroy(share)
    Share.push_shares
    # sync the gh configuration
    # Greyhole.save_conf_file(DiskPoolPartition.all, Share.in_disk_pool)
  end

end
