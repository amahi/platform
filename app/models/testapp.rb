class Testapp < ApplicationRecord

  serialize :installer
  serialize :info

  def get_installer
    return OpenStruct.new(self.installer)
  end

  def get_app
    return OpenStruct.new(self.info)
  end
end
