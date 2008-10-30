class UserSession < Authgasm::Session::Base
  self.remember_me = true
end