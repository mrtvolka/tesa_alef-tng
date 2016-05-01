module ScoringSystem
  class CompleteTestScoring < ScoringSystem::Scoring
    def self.doScoring(exercise_id, user_id)
      rels=UserToLoRelation.where("user_id= (?) AND exercise_id= (?)",user_id,exercise_id)

      correct= true
      rels.each do |relation|
        if relation.type == "UserFailedLoRelation"
          correct=false
        end
      end
      if correct
        rels.each do |relation|
          if relation.type== "UserSolvedLoRelation"
            relation.points= 1.0/rels.size
            relation.save
          end
        end
      else
        rels.each do |relation|
          relation.points=0
          relation.save
        end
      end
    end
  end
end
