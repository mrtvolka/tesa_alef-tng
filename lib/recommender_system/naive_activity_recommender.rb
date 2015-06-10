# Tento odporucac sa snazi pouzivatelovi ponuknut otazky, ktore este nevidel alebo neriesil
module RecommenderSystem
class NaiveActivityRecommender < RecommenderSystem::Recommender

  # kolko learning objektov, s ktorymi pouzivatel naposledy pracoval penalizujeme
  @@ignore_last = 20

  def self.get_list

    # najdi vsekty interakcie pouzivatela s otazkami z daneho tyzdna
    list = Hash.new
    learning_objects.each do |lo|
      list[lo.id] = 1
    end

    # pre kazdu otazku najdi interakciu s najnizsim skore
    relations.each do |rel|
      value = self.evaluate_relation(rel)
      if list[rel.learning_object_id] > value
        list[rel.learning_object_id] = value
      end
    end

    relations.map(&:learning_object_id).reverse.uniq.first(@@ignore_last) do |id|
      list[id] -= 0.2
    end

    normalize list
  end

  def self.evaluate_relation (relation)
    case relation
      when UserVisitedLoRelation
        0.8
      when UserViewedSolutionLoRelation
        0.6
      when UserDidntKnowLoRelation, UserFailedLoRelation
        0.4
      else
        0.2
    end
  end

end
end