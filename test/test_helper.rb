require "test/unit"
require "rubygems"
require "ruby-debug"
require "active_record"
require 'active_record/fixtures'
require File.dirname(__FILE__) + '/../lib/authlogic' unless defined?(Authlogic)
require File.dirname(__FILE__) + '/libs/mock_request'
require File.dirname(__FILE__) + '/libs/mock_cookie_jar'
require File.dirname(__FILE__) + '/libs/mock_controller'
require File.dirname(__FILE__) + '/libs/user'

ActiveRecord::Schema.verbose = false
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")
ActiveRecord::Base.configurations = true
ActiveRecord::Schema.define(:version => 1) do
  create_table :companies do |t|
    t.datetime  :created_at    
    t.datetime  :updated_at
    t.string    :name
    t.boolean   :active
  end

  create_table :projects do |t|
    t.datetime  :created_at      
    t.datetime  :updated_at
    t.string    :name
  end
  
  create_table :projects_users, :id => false do |t|
    t.integer :project_id
    t.integer :user_id
  end
  
  create_table :users do |t|
    t.datetime  :created_at      
    t.datetime  :updated_at
    t.integer   :lock_version, :default => 0
    t.integer   :company_id
    t.string    :login
    t.string    :crypted_password
    t.string    :password_salt
    t.string    :persistence_token
    t.string    :single_access_token
    t.string    :perishable_token
    t.string    :email
    t.string    :first_name
    t.string    :last_name
    t.integer   :login_count
    t.integer   :failed_login_count
    t.datetime  :last_request_at
    t.datetime  :current_login_at
    t.datetime  :last_login_at
    t.string    :current_login_ip
    t.string    :last_login_ip
    t.boolean   :active, :default => true
    t.boolean   :approved, :default => true
    t.boolean   :confirmed, :default => true
  end
  
  create_table :employees do |t|
    t.datetime  :created_at      
    t.datetime  :updated_at
    t.integer   :company_id
    t.string    :email
    t.string    :crypted_password
    t.string    :password_salt
    t.string    :persistence_token
    t.string    :first_name
    t.string    :last_name
    t.integer   :login_count
    t.datetime  :last_request_at
    t.datetime  :current_login_at
    t.datetime  :last_login_at
    t.string    :current_login_ip
    t.string    :last_login_ip
  end
end

class Project < ActiveRecord::Base
  has_and_belongs_to_many :users
end

class UserSession < Authlogic::Session::Base
end

class EmployeeSession < Authlogic::Session::Base
end

class Company < ActiveRecord::Base
  authenticates_many :employee_sessions
  authenticates_many :user_sessions
  has_many :employees, :dependent => :destroy
  has_many :users, :dependent => :destroy
end

Authlogic::CryptoProviders::AES256.key = "myafdsfddddddddddddddddddddddddddddddddddddddddddddddd"

class Employee < ActiveRecord::Base
  acts_as_authentic :crypto_provider => Authlogic::CryptoProviders::AES256
  belongs_to :company
end

class Test::Unit::TestCase
  self.fixture_path = File.dirname(__FILE__) + "/fixtures"
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
  self.pre_loaded_fixtures = true
  fixtures :all
  setup :activate_authlogic
  
  private
    def activate_authlogic
      @controller = MockController.new
      Authlogic::Session::Base.controller = @controller
    end
    
    def password_for(user)
      case user
      when users(:ben)
        "benrocks"
      when users(:zack)
        "zackrocks"
      end
    end
    
    def http_basic_auth_for(user = nil, &block)
      unless user.blank?
        @controller.http_user = user.login
        @controller.http_password = password_for(user)
      end
      yield
      @controller.http_user = @controller.http_password = nil
    end
    
    def set_cookie_for(user, id = nil)
      @controller.cookies["user_credentials"] = {:value => user.persistence_token, :expires => nil}
    end
    
    def unset_cookie
      @controller.cookies["user_credentials"] = nil
    end
    
    def set_params_for(user, id = nil)
      @controller.params["user_credentials"] = user.single_access_token
    end
    
    def unset_params
      @controller.params["user_credentials"] = nil
    end
    
    def set_request_content_type(type)
      @controller.request_content_type = type
    end
    
    def unset_request_content_type
      @controller.request_content_type = nil
    end
    
    def set_session_for(user, id = nil)
      @controller.session["user_credentials"] = user.persistence_token
      @controller.session["user_credentials_id"] = user.id
    end
    
    def unset_session
      @controller.session["user_credentials"] = @controller.session["user_credentials_id"] = nil
    end
end