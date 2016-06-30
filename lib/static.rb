require 'byebug'

class Static

  MIME_TYPES = {
    '.txt' => 'text/plain',
    '.jpg' => 'image/jpeg',
    '.zip' => 'application/zip',
    '.png' => 'image/png'
  }

  def initialize(app)
    @app = app
  end

  def call(env)
    res = Rack::Response.new
    dir_path = File::dirname(__FILE__)
    file_name = env['PATH_INFO']
    file_path = dir_path + '/..' + file_name

    if File.exist?(file_path)
      serve_file(file_path, res)
    else
      res.status = 404
      res.write("File not found")
    end
    res
  end

  private
  def serve_file(filename, res)
    extension = File.extname(filename)
    content_type = MIME_TYPES[extension]
    file = File.read(filename)
    res['Content-type'] = content_type
    res.write(file)
  end
end
