class User < ActiveRecord::Base
  acts_as_authentic
  has_and_belongs_to_many :projects
  belongs_to :company
end
