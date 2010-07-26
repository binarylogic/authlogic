require 'rails'

module Authlogic
  class Railtie < Rails::Railtie
    generators do
      require AUTHLOGIC_PATH + 'rails3_engine/generators/session/session_generator.rb'
    end
  end
end