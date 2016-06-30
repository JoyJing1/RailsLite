require 'rack'
require 'byebug'

app = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new
  res['Content-Type'] = 'text/html'

  url_path = req.url.match(/3000\/(\S+)/)
  res.write(url_path[1])
  res.finish
end

Rack::Server.start(
  app: app,
  Port: 3000
)
