module RecommenderSystem
  class Recommender

    def self.setup(user_id, week_id)
      @@user_id = user_id
      @@week_id = week_id
      @@los = Hash.new
      @@rels = Hash.new
    end

    def self.learning_objects
      if @@los.empty?
        @@los = Week.find(@@week_id).learning_objects.includes(:concepts).distinct
      end
      @@los
    end

    def self.relations
      if @@rels.empty?
        @@rels = UserToLoRelation.where('user_id = (?) AND learning_object_id IN (?)',
                                       @@user_id,
                                       self.learning_objects.map(&:id)
        ).order(:created_at)
      end
      @@rels
    end

    def self.user_id
      @@user_id
    end

    def self.week_id
      @@week_id
    end

    def self.get_list
        los = self.learning_objects
        list = Hash.new
        los.each do |lo|
          list[lo.id] = 0
        end

        list
    end

    def self.get_best
      get_list.first
    end

    def self.normalize list
      max = list.values.max

      unless max == 0
        list.each do |key,val|
          list[key] = val.to_f / max
        end
      end

      list
    end

  end
end