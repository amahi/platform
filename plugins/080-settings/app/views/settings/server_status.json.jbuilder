self.formats = ['html']

json.status :ok
json.content render(partial: 'server', locals: {server: @server})
