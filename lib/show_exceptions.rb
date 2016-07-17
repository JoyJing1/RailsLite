require 'erb'
require 'byebug'

class ShowExceptions
  attr_reader :app

  def initialize(app)
    @app = app
  end

  def call(env)
    begin
      @app.call(env)
    rescue Exception => e
      render_exception(e)
    end
  end

  private
  def render_exception(e)
    dir_path = File.dirname(__FILE__)
    template_fname = File.join(dir_path, "templates", "rescue.html.erb")
    template = File.read(template_fname)
    body = ERB.new(template).result(binding)

    ["500", {'Content-type' => 'text/html'}, body]
  end

end
