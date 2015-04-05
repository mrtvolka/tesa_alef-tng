class Concept < ActiveRecord::Base
  belongs_to :course
  has_and_belongs_to_many :weeks
  has_and_belongs_to_many :learning_objects
end