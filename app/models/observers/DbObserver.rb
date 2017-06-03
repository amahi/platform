class DbObserver < ActiveRecord::Observer

  def after_create(db)
    return unless Rails.env.production?
		c = db.class.connection
		password = name
		user = name
		host = 'localhost'
		c.execute "CREATE DATABASE IF NOT EXISTS `#{name}` DEFAULT CHARACTER SET utf8;"
		# FIXME - why do we have to drop the user first in some cases?!?!!??
		c.execute("DROP USER '#{user}'@'#{host}';") rescue nil
		c.execute "CREATE USER '#{user}'@'#{host}' IDENTIFIED BY '#{password}';"
		c.execute "GRANT ALL PRIVILEGES ON `#{name}`.* TO '#{user}'@'#{host}';"
  end

  def after_destroy(db)
    return unless Rails.env.production?
		user = name
		filename = Time.now.strftime("#{DB_BACKUPS_DIR}/%y%m%d-%H%M%S-#{name}.sql.bz2")
		system("mysqldump --add-drop-table -u#{user} -p#{user} #{name} | bzip2 > #{filename}")
		Dir.chdir(DB_BACKUPS_DIR) do
			system("ln -sf #{filename} latest-#{name}.bz2")
		end
		c = db.class.connection
		host = 'localhost'
		c.execute "drop user '#{user}'@'#{host}';"
		c.execute "drop database if exists `#{name}`;"
  end

end
