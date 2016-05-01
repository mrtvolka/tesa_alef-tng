module ScoringSystem
  class SatanScoring < ScoringSystem::Scoring
    def self.doScoring(exercise_id, user_id)
      rels=UserToLoRelation.where("user_id= (?) AND exercise_id= (?)",user_id,exercise_id)

      rels.each do |relation|
        of_correct_options= Answer.where("learning_object_id=(?) AND is_correct= true",relation.learning_object.id).count
        of_incorrect_options= Answer.where("learning_object_id=(?) AND is_correct= false",relation.learning_object.id).count
        correct_answers= Answer.where("learning_object_id=(?) AND is_correct= true",relation.learning_object.id)

        if(relation.learning_object.type!= "MultiChoiceQuestion")
          if relation.type=== "UserSolvedLoRelation"
            relation.points= 1.0
          elsif relation.type== "userFailedLoRelation"
            relation.points= 0
          end
        else
          points = 0.0
          relhash= eval(relation.interaction)
          relhash.each do |key,array|
            if correct_answers.where("id= (?)",key).empty?
              points+= -1.0/of_incorrect_options
            else
              points+= 1.0/of_correct_options
            end
          end
          if points > 0
            relation.points= points
          else
            relation.points= 0
          end
        end
        relation.save
      end
    end
  end
end
