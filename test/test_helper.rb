# frozen_string_literal: true

require "coveralls"
require "simplecov"
require "simplecov-console"

Coveralls.wear!

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(
  [
    SimpleCov::Formatter::Console,
    # Want a nice code coverage website? Uncomment this next line!
    SimpleCov::Formatter::HTMLFormatter
  ]
)
SimpleCov.start { add_filter "/test/" }

require "byebug"
require "rubygems"
require "minitest/autorun"
require "active_record"
require "active_record/fixtures"
require "timecop"
require "i18n"
require "minitest/reporters"

Minitest::Reporters.use!(Minitest::Reporters::SpecReporter.new)

I18n.load_path << File.dirname(__FILE__) + "/i18n/lol.yml"

case ENV["DB"]
when "mysql"
  ActiveRecord::Base.establish_connection(
    adapter: "mysql2",
    database: ENV.fetch("AUTHLOGIC_DB_NAME", "authlogic"),
    host: ENV.fetch("AUTHLOGIC_DB_HOST", nil),
    port: ENV.fetch("AUTHLOGIC_DB_PORT", nil),
    username: ENV.fetch("AUTHLOGIC_DB_USER", "root")
  )
when "postgres"
  ActiveRecord::Base.establish_connection(
    adapter: "postgresql",
    database: ENV.fetch("AUTHLOGIC_DB_NAME", "authlogic"),
    host: ENV.fetch("AUTHLOGIC_DB_HOST", nil),
    password: ENV.fetch("AUTHLOGIC_DB_PASSWORD", nil),
    port: ENV.fetch("AUTHLOGIC_DB_PORT", nil),
    username: ENV.fetch("AUTHLOGIC_DB_USER", nil)
  )
else
  ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
end

logger = Logger.new(STDOUT)
logger.level = Logger::FATAL
ActiveRecord::Base.logger = logger

if ActiveRecord::VERSION::STRING < "4.1"
  ActiveRecord::Base.configurations = true
end

if ActiveSupport.respond_to?(:test_order)
  ActiveSupport.test_order = :sorted
end

if ActiveRecord::VERSION::STRING < "7.1"
  ActiveRecord::Base.default_timezone = :local
else
  ActiveRecord.default_timezone = :local
end
ActiveRecord::Schema.define(version: 1) do
  create_table :companies do |t|
    t.datetime  :created_at, limit: 6
    t.datetime  :updated_at, limit: 6
    t.string    :name
    t.boolean   :active
  end

  create_table :projects do |t|
    t.datetime  :created_at, limit: 6
    t.datetime  :updated_at, limit: 6
    t.string    :name
  end

  create_table :projects_users, id: false do |t|
    t.integer :project_id
    t.integer :user_id
  end

  create_table :users do |t|
    t.datetime  :created_at, limit: 6
    t.datetime  :updated_at, limit: 6
    t.integer   :lock_version, default: 0
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
    t.integer   :login_count, default: 0, null: false
    t.integer   :failed_login_count, default: 0, null: false
    t.datetime  :last_request_at, limit: 6
    t.datetime  :current_login_at, limit: 6
    t.datetime  :last_login_at, limit: 6
    t.string    :current_login_ip
    t.string    :last_login_ip
    t.boolean   :active, default: true
    t.boolean   :approved, default: true
    t.boolean   :confirmed, default: true
  end

  create_table :employees do |t|
    t.datetime  :created_at, limit: 6
    t.datetime  :updated_at, limit: 6
    t.integer   :company_id
    t.string    :email
    t.string    :crypted_password
    t.string    :password_salt
    t.string    :persistence_token
    t.string    :first_name
    t.string    :last_name
    t.integer   :login_count, default: 0, null: false
    t.datetime  :last_request_at, limit: 6
    t.datetime  :current_login_at, limit: 6
    t.datetime  :last_login_at, limit: 6
    t.string    :current_login_ip
    t.string    :last_login_ip
  end

  create_table :affiliates do |t|
    t.datetime  :created_at, limit: 6
    t.datetime  :updated_at, limit: 6
    t.integer   :company_id
    t.string    :username
    t.string    :pw_hash
    t.string    :pw_salt
    t.string    :persistence_token
  end

  create_table :ldapers do |t|
    t.datetime  :created_at, limit: 6
    t.datetime  :updated_at, limit: 6
    t.string    :ldap_login
    t.string    :persistence_token
  end

  create_table :admins do |t|
    t.datetime  :created_at, limit: 6
    t.datetime  :updated_at, limit: 6
    t.string    :login
    t.string    :crypted_password
    t.string    :password_salt
    t.string    :persistence_token
    t.string    :perishable_token
    t.string    :email
    t.string    :role
  end
end

require "English"
$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "authlogic"
require "authlogic/test_case"

# Configure SCrypt to be as fast as possible. This is desirable for a test
# suite, and would be the opposite of desirable for production.
Authlogic::CryptoProviders::SCrypt.max_time = 0.001 # 1ms
Authlogic::CryptoProviders::SCrypt.max_mem = 1024 * 1024 # 1MB, the minimum SCrypt allows

require "libs/project"
require "libs/affiliate"
require "libs/employee"
require "libs/employee_session"
require "libs/ldaper"
require "libs/user"
require "libs/user_session"
require "libs/company"
require "libs/admin"

module ActiveSupport
  class TestCase
    include ActiveRecord::TestFixtures
    self.fixture_path = File.dirname(__FILE__) + "/fixtures"

    # use_transactional_fixtures= is deprecated and will be removed from Rails 5.1
    # (use use_transactional_tests= instead)
    if respond_to?(:use_transactional_tests=)
      self.use_transactional_tests = false
    else
      self.use_transactional_fixtures = false
    end

    self.use_instantiated_fixtures = false
    self.pre_loaded_fixtures = false
    fixtures :all
    setup :activate_authlogic
    setup :config_setup
    teardown :config_teardown
    teardown { Timecop.return } # for tests that need to freeze the time

    private

    # Many of the tests change Authlogic config for the test models. Some tests
    # were not resetting the config after tests, which didn't surface as broken
    # tests until Rails 4.1 was added for testing. This ensures that all the
    # models start tests with their original config.
    def config_setup
      [
        Project,
        Affiliate,
        Employee,
        EmployeeSession,
        Ldaper,
        User,
        UserSession,
        Company,
        Admin
      ].each do |model|
        unless model.respond_to?(:original_acts_as_authentic_config)
          model.class_attribute :original_acts_as_authentic_config
        end
        model.original_acts_as_authentic_config = model.acts_as_authentic_config
      end
    end

    def config_teardown
      [
        Project,
        Affiliate,
        Employee,
        EmployeeSession,
        Ldaper,
        User,
        UserSession,
        Company,
        Admin
      ].each do |model|
        model.acts_as_authentic_config = model.original_acts_as_authentic_config
      end
    end

    def env_session_options
      controller.request.env.fetch(
        ::Authlogic::ControllerAdapters::AbstractAdapter::ENV_SESSION_OPTIONS,
        {}
      ).with_indifferent_access
    end

    def password_for(user)
      case user
      when users(:ben)
        "benrocks"
      when users(:zack)
        "zackrocks"
      when users(:aaron)
        "aaronrocks"
      end
    end

    def http_basic_auth_for(user = nil)
      unless user.blank?
        controller.http_user = user.login
        controller.http_password = password_for(user)
      end
      yield
      controller.http_user = controller.http_password = controller.realm = nil
    end

    def set_cookie_for(user)
      controller.cookies["user_credentials"] = {
        value: "#{user.persistence_token}::#{user.id}",
        expires: nil
      }
    end

    def unset_cookie
      controller.cookies["user_credentials"] = nil
    end

    def set_params_for(user)
      controller.params["user_credentials"] = user.single_access_token
    end

    def unset_params
      controller.params["user_credentials"] = nil
    end

    def set_request_content_type(type)
      controller.request_content_type = type
    end

    def unset_request_content_type
      controller.request_content_type = nil
    end

    def session_credentials_prefix(scope_record)
      if scope_record.nil?
        ""
      else
        format(
          "%s_%d_",
          scope_record.class.model_name.name.underscore,
          scope_record.id
        )
      end
    end

    # Sets the session variables that `record` (eg. a `User`) would have after
    # logging in.
    def set_session_for(record)
      record_class_name = record.class.model_name.name.underscore
      controller.session["#{record_class_name}_credentials"] = record.persistence_token
      controller.session["#{record_class_name}_credentials_id"] = record.id
    end

    def unset_session
      controller.session["user_credentials"] = controller.session["user_credentials_id"] = nil
    end
  end
end
