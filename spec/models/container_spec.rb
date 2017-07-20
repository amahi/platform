require 'spec_helper'

RSpec.describe Container, type: :model do
  describe "test container creation" do
    it "runs after creation" do
      expect(Testapp.count).to eq(2)
      app = App.new("php5") # Create an app object
      app.install_bg # Install it
      c = Docker::Container.get('php5') # This will throw exception if container is not running
    end

    # Cleanup
    # Removes container after testing
    after(:each) do
      puts "removing container"
      c = Docker::Container.get('php5')
      c.stop
      c.remove
    end
  end
end
