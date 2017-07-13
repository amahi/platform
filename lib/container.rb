require 'docker'

# A wrapper class for containers.
# Internally it uses docker-api gem to perform different tasks
class Container
  DOCKER_URL = '/var/run/docker.sock'
  def initialize(id=nil, options=nil)
    @id = id
    @options = options;
    # Check if container already exists and is running
    # If not running then make @container nil
    begin
      @container = Docker::Container.get(@id)
    rescue
      @container = nil
    end
  end

  # This function runs the container with the options provided
  def create
    @image = @options[:image]
    image = Docker::Image.get(@image) rescue nil
    if image.nil?
      # Image not found and hence could not create the container
      raise "Image amahi/#{@id} not found"
    end

    # Create container using build file and volume
    container = Docker::Container.create(
        'name' => "#{@id}",
        'Image' => @image,
        "HostConfig" => {
            "Binds" => ["#{@options[:volume]}/html:/var/www/html" , "/var/lib/mysql/mysql.sock:/var/run/mysql.sock"],
            "PortBindings" =>{ "80/tcp" => [{ "HostPort" => @options[:port].to_s }] },
            "RestartPolicy"=>{ "Name" => "unless-stopped"}
            }
    )
    puts "Successfully created the container time to run it"
    puts container

    container.start
    return true
  end

  def remove
    # Use docker api to stop the running container and then remove it.
    # Functions provided by docker api
    @container.stop
    @container.remove
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