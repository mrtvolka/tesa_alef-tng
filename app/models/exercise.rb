class Exercise < ActiveRecord::Base
  has_many :user_to_lo_relations, dependent: :destroy
  belongs_to :week
  belongs_to :user
  has_and_belongs_to_many :concepts
  validates :code, uniqueness: true


  store_accessor :options, :exercise_concepts, :week_concepts, :cooldown_time, :test_length
  accepts_nested_attributes_for :concepts

  def unavailable_answers? (user)
    if real_end == nil || (!options.nil? && real_end+options['cooldown_time'].to_i.minutes > Time.now && user.student?)
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

  def test_length_defined?
    if options.nil? || options['test_length'].empty?
      false
      return
    end
    true
  end

  def test_time_left
    if test_length_defined?
      time_left = real_start + options['test_length'].to_i.minutes - Time.now
      time_left>0 ? time_left : 0
    else
      0
    end
  end
end