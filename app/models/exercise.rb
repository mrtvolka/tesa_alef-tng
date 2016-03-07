class Exercise < ActiveRecord::Base
  has_many :user_to_lo_relations
  belongs_to :week
  belongs_to :user

  def unavailable_answers? (user)
    if real_end == nil || (real_end+cooldown_time_amount.minutes > Time.now && user.student?)
      true
    else
      false
    end
  end
end