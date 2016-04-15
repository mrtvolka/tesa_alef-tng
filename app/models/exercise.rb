class Exercise < ActiveRecord::Base
  has_many :user_to_lo_relations, dependent: :destroy
  belongs_to :week
  belongs_to :user
  has_and_belongs_to_many :concepts
  validates :code, uniqueness: true


  store_accessor :options, :exercise_concepts, :week_concepts, :cooldown_time, :test_length
  accepts_nested_attributes_for :concepts

  def unavailable_answers? (user)
    if real_end == nil || (real_end+cooldown_time_amount.minutes > Time.now && user.student?)
      true
    else
      false
    end
  end

  def change_concepts(concepts)
    self.concepts.delete_all
    concepts.each do |concept|
      if !concept.empty?
        self.concepts << Concept.find(concept)
      end
    end
  end

  def generatecode()
    self.code = loop do
      random_code = SecureRandom.random_number(Exercise.count + 2) + 1
      puts random_code.to_s
      break random_code unless Exercise.exists?(code: random_code)
    end
  end
end