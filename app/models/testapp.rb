class Testapp < ApplicationRecord

  serialize :installer
  serialize :info
  serialize :uninstaller
  
  def get_installer
    return OpenStruct.new(self.installer)
  end

  def get_app
    return OpenStruct.new(self.info)
  end

  def get_uninstaller
    return OpenStruct.new(self.uninstaller)
  end
end
