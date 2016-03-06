class Exercise < ActiveRecord::Base
  has_many :user_to_lo_relations
  belongs_to :week
  belongs_to :user

  def unavailable_answers?
    if real_end == nil || real_end+cooldown_time_amount.minutes > Time.now
      true
    else
      false
    end
  end
end