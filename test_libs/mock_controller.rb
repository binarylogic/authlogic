class MockController < Authlogic::ControllerAdapters::AbstractAdapter
  attr_accessor :http_user, :http_password
  
  def initialize
  end
  
  def authenticate_with_http_basic(&block)
    yield http_user, http_password
  end
  
  def cookies
    @cookies ||= MockCookieJar.new
  end
  
  def request
    @request ||= MockRequest.new
  end
  
  def session
    @session ||= {}
  end
end