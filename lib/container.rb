require 'docker'

class Container
  DOCKER_URL = '/var/run/docker.sock'
  def initialize(id=nil, port=nil, options=nil)
    @id = id
    @port = port.to_s
    @volume = options[:volume]
    begin
      @container = Docker::Container.get(@id)
    rescue
      @container = nil
    end
  end

  def create
    image = Docker::Image.get("amahi/#{@id}") rescue nil
    if image.nil?
      # Image not found and hence could not create the container
      raise "Image amahi/#{@id} not found"
    end

    # TODO: Take care of the restart policies
    # Create container using build file and volume
    container = Docker::Container.create(
        'name' => "#{@id}",
        'Image' => 'richarvey/nginx-php-fpm:php5',
        "HostConfig" => {
            "Binds" => ["#{@volume}/html:/var/www/html" ],
            "PortBindings" =>{ "80/tcp" => [{ "HostPort" => @port }] }
        }
    )
    puts "Successfully created the container time to run it"
    puts container

    container.start
    return true
  end

  private
  def running?
    # Check : Is it ok to write like this?
    begin
      container = Docker::Container.get(@id)
      return true
    rescue => e
      return false
    end
  end

  def exists?
    return alse if @container.nil? # Container is not initialized or created yet
    begin
      # Container.get raises an exception
      container = Docker::Container.get(@id)
      if !container.nil?
        return true
      else
        return false
      end
    rescue => e
      return false
    end
  end
end