# frozen_string_literal: true

class Company < ActiveRecord::Base
  has_many :employees, dependent: :destroy
  has_many :users, dependent: :destroy
end
