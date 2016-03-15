class UserToLoRelation < ActiveRecord::Base
  belongs_to :learning_object
  belongs_to :setup
  belongs_to :user
  belongs_to :exercise

  def self.get_basic_relations(los, user_id)
    self.
        where("learning_object_id IN (?)", los.map(&:id)).
        where("user_id = ?", user_id).
        where("type = 'UserVisitedLoRelation' OR type = 'UserSolvedLoRelation'").
        group(:learning_object_id, :type).count
  end

  def self.get_results(user_id,week_id)
    sql = '
      SELECT los.id as result_id,
      sum(case when rels.type = \'UserVisitedLoRelation\' then 1 else 0 end) as visited,
      sum(case when rels.type = \'UserSolvedLoRelation\' then 1 else 0 end) as solved
      FROM
      (
        SELECT learning_objects.*
        FROM "learning_objects"
        INNER JOIN "concepts_learning_objects" ON "learning_objects"."id" = "concepts_learning_objects"."learning_object_id"
        INNER JOIN "concepts" ON "concepts_learning_objects"."concept_id" = "concepts"."id"
        INNER JOIN "concepts_weeks" ON "concepts"."id" = "concepts_weeks"."concept_id"
        WHERE "concepts_weeks"."week_id" = '+week_id.to_s+'
        GROUP BY learning_objects.id
      ) AS los
      LEFT JOIN user_to_lo_relations as rels ON rels.learning_object_id = los.id
      WHERE user_id = '+user_id.to_s+' AND rels.exercise_id IS NULL
      GROUP BY los.id
    '
    ActiveRecord::Base.connection.execute(sql)
  end

  def self.to_csv
    selected_columns = ['user_id','learning_object_id','type','interaction','submitted_text']
    output_column_names = ['Meno študenta','Otázka','Výsledok','Označené','Textová odpoveď']
    CSV.generate(:col_sep => "|") do |csv|
      csv << output_column_names
      all.each do |answer|
        csv_values = []
        #answer.attributes.values_at(*selected_columns).each do |attr_value|
        answer.attributes.select{|k, v| selected_columns.include?(k)}.each do |attr_name, attr_value|
          if attr_name == 'user_id'
            user = User.find_by_id(attr_value)
            attr_value = user.aisid + ": " + user.first_name + " " + user.last_name
          elsif attr_name == 'learning_object_id'
            question = LearningObject.find_by_id(attr_value)
            # lo_id + id because of potential duplicity of lo_id values
            attr_value = question.lo_id + "_" + question.id.to_s
          elsif attr_name == 'type'
            case attr_value
              when 'UserVisitedLoRelation'
                attr_value = 'videné'
              when 'UserSolvedLoRelation'
                attr_value = 'správne'
              when 'UserFailedLoRelation'
                attr_value = 'nesprávne'
              when 'UserSubmittedLoRelation'
                attr_value = 'odoslané'
              when 'UserCompletedLoRelation'
                attr_value = 'dokončené'
              when 'UserDidntKnowLoRelation'
                attr_value = 'neodpovedané'
              else
            end
          elsif attr_name == 'interaction'
            # TODO: answer numbers
          else
          end
          csv_values << attr_value
        end
        csv << csv_values
      end
    end
  end

end