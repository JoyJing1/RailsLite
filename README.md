# RailsLite

Rails Lite is an academic exercise in implementing the main functionality of Rails and its ability to leverage convention over configuration.

The purpose was to deeply understand how Rails works, with a focus on Model-View-Controller (MVC) architecture and metaprogramming. It is written in pure Ruby.

## Demo

Some specs have been written to demonstrate the functionality of the project. To run the specs:

1. In terminal, `git clone https://github.com/JoyJing1/RailsLite.git`
2. `cd RailsLite`

Running them in the following order will follow the progression of the project.

### Suggested Order
1. `rspec spec/p00_controller_spec.rb`
2. `rspec spec/p01_template_spec.rb`
3. `rspec spec/p02_session_spec.rb`
4. `rspec spec/p03_router_spec.rb`
5. `rspec spec/p04_integration_spec.rb`
5. `rspec spec/p05_flash_spec.rb`
5. `rspec spec/p06_exceptions_spec.rb`
5. `rspec spec/p07_static_spec.rb`
5. `rspec spec/p08_csrf_spec.rb`

## Code Snippets

### Controller

Setup the controller
```ruby
class ControllerBase
  attr_reader :req, :res, :params, :flash

  def initialize(req, res, params={} )
    @req, @res = req, res
    @params = params.merge(req.params)
    @already_built_response = false
    @flash = Flash.new(req)
    @@protect_from_forgery ||= false
  end
end
```

Set the response status code and header

```ruby
def redirect_to(url)
  raise "Double render error" if already_built_response?

  @res['location'] = url
  @res.status = 302
  @already_built_response = true

  session.store_session(@res)
  flash.store_flash(@res)
  nil
end
```

Populate the response with content. Set the response's content type to the given type, and raise an error if the developer tries to double render.

```ruby
def render_content(content, content_type)
  raise "Double render error" if already_built_response?

  @res['Content-Type'] = content_type
  @res.write(content)
  @already_built_response = true

  session.store_session(@res)
  flash.store_flash(@res)
  nil
end
```

### Sessions
Serialize the hash data into json and save as a cookie. Add cookie to the response cookies.

```ruby
class Session
  def store_session(res)
    res.set_cookie('_rails_lite_app', {:path => '/', :value => @data.to_json} )
  end
end
```

### Routes
```ruby
class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern, @http_method, @controller_class, @action_name = pattern, http_method, controller_class, action_name
  end
end
```

Code to create default routes
```ruby
[:get, :post, :put, :delete].each do |http_method|
  define_method(http_method) do |pattern, controller_class, action_name|
    add_route(pattern, http_method, controller_class, action_name)
  end
end
```

### Exception Handling
```ruby
class ShowExceptions
  def render_exception(e)
    dir_path = File.dirname(__FILE__)
    template_fname = File.join(dir_path, "templates", "rescue.html.erb")
    template = File.read(template_fname)
    body = ERB.new(template).result(binding)

    ["500", {'Content-type' => 'text/html'}, body]
  end
end
```

### CSRF Prevention - Cross-Site Request Forgery
```ruby
class ControllerBase
  def form_authenticity_token
    cookie = @res.headers['Set-Cookie']
    @token = cookie['authenticity_token'] if cookie
    @token ||= generate_authenticity_token
    @res.headers['Set-Cookie'] = {'authenticity_token' => @token }
    @token
  end
end
```

Developed by [Joy Jing][joy-jing]
[joy-jing]: https://joyjing1.github.io/
