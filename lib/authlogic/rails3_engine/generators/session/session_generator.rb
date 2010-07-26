module Authlogic
  class SessionGenerator < Rails::Generators::NamedBase
    source_root File.expand_path("../templates", __FILE__)
  
    def create_session_model
      class_collisions class_name
      template 'session.rb', File.join('app/models', class_path, "#{file_name}.rb")
    end
  end
end