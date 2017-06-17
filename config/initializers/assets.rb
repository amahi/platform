# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
#
# see https://bugs.amahi.org/issues/2233 for details as to why
Rails.application.config.assets.precompile << /(^[^_\/]|\/[^_])[^\/]*$/