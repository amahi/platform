# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.

Rails.application.config.assets.precompile += %w( login.css )
Rails.application.config.assets.precompile += %w( users.css )
Rails.application.config.assets.precompile += %w( shares.css )
Rails.application.config.assets.precompile += %w( disks.css )
Rails.application.config.assets.precompile += %w( apps.css )
Rails.application.config.assets.precompile += %w( network.css )
Rails.application.config.assets.precompile += %w( settings.css )

Rails.application.config.assets.precompile += %w( login.js )
Rails.application.config.assets.precompile += %w( users.js )
Rails.application.config.assets.precompile += %w( shares.js )
Rails.application.config.assets.precompile += %w( disks.js )
Rails.application.config.assets.precompile += %w( apps.js )
Rails.application.config.assets.precompile += %w( network.js )
Rails.application.config.assets.precompile += %w( settings.js )

