class Company < ActiveRecord::Base
  has_many :users, :dependent => :destroy
  authenticates_many :user_sessions, :scope_cookies => true
end
