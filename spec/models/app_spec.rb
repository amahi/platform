require 'spec_helper'

describe App do

  describe "normal app installation" do
    # Test if a normal app installs correctly
    it "installs correctly" do
      app = App.new("normal") # Create an app object
      app.install_bg # Install it
      expect(App.count).to eq(1) # Verifies if app is installed or not
      # TODO: Add test case for config files if needed
      #puts app.webapp.get_conf
    end

    # Test if a normal app uninstalls correctly
    it "uninstalls correctly" do
      app = App.new("normal")
      app.install_bg # Install it
      expect(App.count).to eq(1)

      app.uninstall_bg
      expect(App.count).to eq(0)
    end
  end

  describe "php5 installation" do
    # Test if a php5 app installs correctly
    it "installs correctly" do
      app = App.new('php5')
      app.install_bg
      expect(App.count).to eq(1)
      expect(Container.count).to eq(1)
    end

    # Test if a php5 app uninstalls correctly
    it "uninstalls correctly" do
      app = App.new("php5") # Create an app object
      app.install_bg # Install it
      expect(App.count).to eq(1)

      app.uninstall_bg
      expect(App.count).to eq(0)
      expect(Container.count).to eq(0)

      # Test if container was stopped and removed from the system or not
      expect {
        c = Docker::Container.get('php5')
      }.to raise_error(Exception)
    end

    # Clean up to remove the container if running
    after(:each) do
      puts "removing container"
      # Removing app must remove the container.
      # If not then the code below takes care of that
      begin
        c = Docker::Container.get('php5')
        c.stop
        c.remove
      rescue Exception=>e
        # We dont want to catch exception because we are
        # expecting an exception
        puts e
      end
    end
  end

  # To add tests for any new kind of app add another describe block here
  # Make sure you create a new testapp and place it inside seeds.rb
end