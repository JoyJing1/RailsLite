require 'active_support'
require 'active_support/core_ext'
require 'active_support/inflector'
require 'erb'
require_relative './session'
require_relative 'flash'
require 'byebug'

class ControllerBase
  attr_reader :req, :res, :params, :flash

  # Setup the controller
  def initialize(req, res, params={} )
    @req, @res = req, res
    @params = params.merge(req.params)
    @already_built_response = false
    @flash = Flash.new(req)
    @@protect_from_forgery ||= false
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    raise "Double render error" if already_built_response?
    @res['location'] = url
    @res.status = 302
    @already_built_response = true
    session.store_session(@res)
    flash.store_flash(@res)
    nil
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    raise "Double render error" if already_built_response?
    @res['Content-Type'] = content_type
    @res.write(content)
    @already_built_response = true
    session.store_session(@res)
    flash.store_flash(@res)
    nil
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    #Use controller & template_name to construct path
    directory_path = Dir.pwd
    # dir_path = File.dirname(__FILE__)
    path = directory_path + '/views/' + self.class.to_s.underscore + '/' + template_name.to_s + '.html.erb'
    f = File.read(path) #Use File.red to read template file
    #Create new ERB template from contents
    #Evaluate ERB template using binding to capture controller's instance vaiarlbes
    content = ERB.new(f).result(binding)
    #result(binding) - allows you to pull out/use anything in ERB tag
    #Pass result ot render_content with a content_type='text/html'
    render_content(content, 'text/html')
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  def flash
    @flash ||= Flash.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    if protect_from_forgery? && req.request_method != "GET"
      check_authenticity_token
    else
      form_authenticity_token
    end
    #Use #send to call appropriate action
    self.send(name)
    render(name) unless already_built_response?
    #Check to see if a template was rendered
    #If not, call #render
    nil
  end

  def form_authenticity_token
    cookie = @res.headers['Set-Cookie']
    @token = cookie['authenticity_token'] if cookie
    @token ||= generate_authenticity_token
    @res.headers['Set-Cookie'] = {'authenticity_token' => @token }
    @token
  end


  def check_authenticity_token
     cookie = @req.cookies["authenticity_token"]
     unless cookie && cookie == params["authenticity_token"]
       raise "Invalid authenticity token"
     end
   end

  def self.protect_from_forgery
    @@protect_from_forgery = true
  end

  def protect_from_forgery?
    @@protect_from_forgery
  end

  def generate_authenticity_token
    SecureRandom.urlsafe_base64(16)
  end

end
