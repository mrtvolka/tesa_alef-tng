# Simple recommeder for choosing students test questions
# based on randomization of numbers
module RecommenderSystem
  class TesaSimpleRecommender < RecommenderSystem::Recommender

    def self.setup(user_id, week_id, access_key)
      @@access_key = access_key
      super(user_id,week_id)
    end

    def get_list
      # get all weeks test questions
      all_questions = self.test_learning_objects.where(is_test_question: TRUE)
      exercise_questions = Hash.new
      student_questions = Hash.new
      list = Hash.new

      # adding special questions for all students
      special_questions = all_questions.where(is_special_question: TRUE)
      all_questions -= special_questions
      special_questions.each do |special_question|
        list[special_question.id] = 1
      end

      # set questions counts
      all_questions_count = all_questions.length
      # TODO setting these parameters for subject, actual for OS
      # exercise_questions_count > student_questions_count
      exercise_questions_count = 7
      student_questions_count = 4

      # reduce student questions count
      student_questions_count -= special_questions.length

      # change questions counts to as many as possible
      exercise_questions_count = all_questions_count if exercise_questions_count > all_questions_count
      student_questions_count = exercise_questions_count if student_questions_count > exercise_questions_count

      # select specific number of questions for exercise
      srand(access_key.to_i)
      (1..exercise_questions_count).each do
        # try generate random number
        begin
          # generate random number with exercise test access key seed
          random_number = random_value(all_questions_count)
          # numbers must be unique!
        end until !exercise_questions.has_key? random_number
        exercise_questions[random_number] = 1
      end

      srand(user_id.id)
      (1..student_questions_count).each do
        begin
          # generate random number with current time seed
          random_number = random_value(exercise_questions_count)
          # numbers must be unique!
        end until !student_questions.has_key? random_number
        student_questions[random_number] = 1
      end

      # specify final list of questions
      (0..student_questions_count-1).each do |i|
        # select final question with id (hash with key=id, value = 1)
        list[all_questions[exercise_questions.keys[student_questions.keys[i]]].id] = 1
      end

      normalize list
    end

    def access_key
      @@access_key
    end

    def random_value(range)
      value = rand(range)
      value
    end

    def random_value_seed(range)
      srand()
      value = rand(range)
      value
    end
  end
end