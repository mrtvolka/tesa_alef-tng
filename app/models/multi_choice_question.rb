class MultiChoiceQuestion < LearningObject

  # Returns correct options
  def get_solution(user_id)
    self.answers.where(is_correct: true).ids
  end

  # Constructs hash for right answer, which has same format as hash posted in student response.
  def construct_righ_hash
    #{"8"=>"8", "10"=>"10", "11"=>"11"}
    answers= Answer.where("learning_object_id = (?) ANd is_correct = true",self.id)
    response= '{'
    answers.each  do |key, val|
      response << "\"#{key.id}\"=>\"#{key.id}\","
    end
    response=response.chomp(',')
    response << '}'
    return response
  end

  def right_answer?(answer, solution)

    if answer == nil
      return solution.empty?
    end

    answer = answer.values.map { |n| n.to_i }
    solution == answer

  end
end