require 'spec_helper'

describe App do

  describe "normal app installation" do
    it "installs correctly" do
      app = App.new("xyz") # Create an app object
      app.install_bg # Install it
      expect(App.count).to eq(1) # Verifies if app is installed or not
      # TODO: Add test case for config files if needed
      #puts app.webapp.get_conf
    end
  end


  describe "php5 installation" do
    it "installs correctly"
    # Clean up everything
    after(:context) do
      # Stop and remove the created image
    end
  end
end