require 'json'

class Flash
  def initialize(req)
    @req = req
    cookie = req.cookies['_rails_lite_app_flash']
    @data = (cookie ? JSON::parse(cookie) : {})
    @data_now = {}
  end

  def [](key)
    @data_now[key] || @data[key]
  end

  def []=(key, val)
    @data_now[key] = val
    @data[key] = val
  end

  def now
    @data_now
  end
  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_flash(res)
    res.set_cookie('_rails_lite_app_flash', {:path => '/', :value => @data.to_json} )
  end
end
