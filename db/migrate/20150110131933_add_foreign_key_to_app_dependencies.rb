class AddForeignKeyToAppDependencies < ActiveRecord::Migration
  def change
    add_foreign_key(:app_dependencies, :apps)
  end
end
