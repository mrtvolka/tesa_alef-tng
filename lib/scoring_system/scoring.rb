module ScoringSystem
  class Scoring

    # Computes points for specific test. If answer is entirely correct it grants one point if not it grants no points
    def self.doScoring(exercise_id, user_id)
      rels=UserToLoRelation.where("user_id= (?) AND exercise_id = (?)",user_id,exercise_id)

      rels.each do |relation|
        if relation.type == "UserFailedLoRelation"
          relation.points= 0
        elsif relation.type == "UserSolvedLoRelation"
          relation.points= 1.0
        end
        relation.save
      end
    end

    # Method that scores test for all students. It invokes <tt>doScoring</tt> for every student
    def self.doScoringForExercise(exercise_id)
      rels=UserToLoRelation.where("exercise_id= (?)",exercise_id)

      uids= rels.select(:user_id).distinct

      uids.each do |uid|
        doScoring(exercise_id,uid.user_id)
      end
    end
  end
end
