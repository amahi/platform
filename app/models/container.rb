class Container < ApplicationRecord
  DOCKER_URL = '/var/run/docker.sock'
  belongs_to :app
  after_destroy :remove_container

  validates_uniqueness_of :name
  validates_presence_of :app

  serialize :options
  def running?
    # Check : Is it ok to write like this?
    begin
      container = get_docker_container
      return true
    rescue => e
      return false
    end
  end

  # Exactly similar to running
  def exists?
    running?
  end

  def run_container
    options = parse_options
    image = options.image
    image = Docker::Image.get(image) rescue nil
    if image.nil?
      # Image not found and hence could not create the container
      raise "Image #{options.image} not found"
    end

    # Create container using build file and volume
    config = {
        'name' => self.name,
        'Image' => options.image,
        "HostConfig" => {
            "Binds" => ["#{options.volume}/html:/var/www/html" , "/var/lib/mysql/mysql.sock:/var/run/mysql.sock"],
            "PortBindings" =>{ "#{options.container_port}/tcp" => [{ "HostPort" => options.port.to_s }] },
            "RestartPolicy"=>{ "Name" => "unless-stopped"},
            "Links" => []
        }
    }

    # Why is mongo express starting on port 8081
    # Shift the port mapping somehow. How do we do that?
    if(self.kind=="node")
      # Make sure that the mongo container is running. If not running then run it.
      puts "time to run a node container"
      begin
        mongo = Docker::Container.get('mongo')
        puts "Mongo container running!"
      rescue Exception => e
        puts e
        image = Docker::Image.create('fromImage' => 'mongo:3.5')
        mongo = Docker::Container.create(
            'name' => 'mongo',
            'Image' => 'mongo:3.5',
            "HostConfig" => {
                "PortBindings" =>{ "27017/tcp" => [{ "HostPort" => "27017" }] },
                "RestartPolicy"=>{ "Name" => "unless-stopped"}
            }
        )
        puts "Created new mongo container. Starting it up"
        mongo.start
        # FIXME: Shift this installation process to hda-platform installation
      end
      # Add a link so that the app can interact with mongodb
      config["HostConfig"]["Links"].push("mongo")
    end
    container = Docker::Container.create(config)
    puts "Successfully created the container time to run it"
    puts container
    container.start
    return true
  end
  private
  def remove_container
    if self.running?
      docker_container = get_docker_container
      docker_container.stop
      docker_container.remove
    end
  end

  # Returns a container object created by docker-api
  def get_docker_container
    container = Docker::Container.get(self.name)
    return container
  end

  def parse_options
    OpenStruct.new(self.options)
  end
end
