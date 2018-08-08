# frozen_string_literal: true

class UserSession < Authlogic::Session::Base
end

class BackOfficeUserSession < Authlogic::Session::Base
end

class WackyUserSession < Authlogic::Session::Base
  attr_accessor :counter
  authenticate_with User

  def initialize
    @counter = 0
    super
  end

  def persist_by_false
    self.counter += 1
    false
  end

  def persist_by_true
    self.counter += 1
    true
  end
end
