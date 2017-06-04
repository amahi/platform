class ThemeObserver < ActiveRecord::Observer

  def before_destroy(theme)
    Dir.chdir(File.join(Rails.root, THEME_ROOT)) do
      FileUtils.rm_rf theme.css
    end
  end
  
end
