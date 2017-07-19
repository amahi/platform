class Container < ApplicationRecord
  DOCKER_URL = '/var/run/docker.sock'
  belongs_to :app

  after_create :run_container

  after_destroy :remove_container

  validates_uniqueness_of :name
  validates_presence_of :app

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

  private
  def run_container
    options = parse_options
    image = options.image
    image = Docker::Image.get(image) rescue nil
    if image.nil?
      # Image not found and hence could not create the container
      raise "Image amahi/#{@id} not found"
    end

    # Create container using build file and volume
    container = Docker::Container.create(
        'name' => self.name,
        'Image' => options.image,
        "HostConfig" => {
            "Binds" => ["#{options.volume}/html:/var/www/html" , "/var/lib/mysql/mysql.sock:/var/run/mysql.sock"],
            "PortBindings" =>{ "80/tcp" => [{ "HostPort" => options.port.to_s }] },
            "RestartPolicy"=>{ "Name" => "unless-stopped"}
        }
    )
    puts "Successfully created the container time to run it"
    puts container
    container.start
    return true
  end

  def remove_container
    if self.running?
      docker_container = self.get_docker_container
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
    OpenStruct.new(JSON.parse(self.options))
  end
end
