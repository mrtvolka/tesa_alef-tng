class Course < ActiveRecord::Base
  has_many :setups
  has_many :concepts
  has_many :learning_objects
end