class Exercise < ActiveRecord::Base
  has_many :user_to_lo_relations
  belongs_to :week
  belongs_to :user
  has_and_belongs_to_many :concepts

  def unavailable_answers? (user)
    if real_end == nil || (real_end+cooldown_time_amount.minutes > Time.now && user.student?)
      true
    else
      false
    end
  end
end