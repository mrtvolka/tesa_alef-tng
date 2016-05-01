module ScoringSystem
  class Scoring
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

    def self.doScoringForExercise(exercise_id)
      rels=UserToLoRelation.where("exercise_id= (?)",exercise_id)

      uids= rels.select(:user_id).distinct

      uids.each do |uid|
        doScoring(exercise_id,uid.user_id)
      end
    end
  end
end
