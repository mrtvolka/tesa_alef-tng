class Exercise < ActiveRecord::Base
  has_many :user_to_lo_relations
  belongs_to :week
  belongs_to :user
end