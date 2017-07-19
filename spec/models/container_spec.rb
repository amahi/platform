require 'spec_helper'

RSpec.describe Container, type: :model do
  describe "test creation" do
    it "runs after creation" do
      app = App.new("xyz") # Create an app object
      app.install_bg # Install it

      app.containers.create(:name=> "xyz", :options => {:image => "amahi/xyz", :volume => '/home/viky/test/1', :port => 35000+app.id}.to_json)
      # Verify if container is up and running
      c = Docker::Container.get('xyz') # This will throw exception if container is not running
    end

    # Cleanup
    # Removes container after testing
    after(:each) do
      puts "removing container"
      c = Docker::Container.get('xyz')
      c.stop
      c.remove
    end
  end
end
