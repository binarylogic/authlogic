class UserSession < Authlogic::Session::Base
end

class BackOfficeUserSession < Authlogic::Session::Base
  authenticate_with User
end
