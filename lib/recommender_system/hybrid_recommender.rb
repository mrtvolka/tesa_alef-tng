module RecommenderSystem
  class HybridRecommender < RecommenderSystem::Recommender

  def self.get_list

    # Najde prislusnu konfiguraciu odporucania
    linker = RecommendationLinker.find_by(user_id: self.user_id, week_id: self.week_id)
    if linker.nil?
      config = RecommendationConfiguration.find_by_default(true)
    else
      config = RecommendationConfiguration.find(linker.recommendation_configuration_id)
    end


    # Vytvori list, do ktoreho sa budu ukladat vysledky odporucani
    list = Hash.new
    learning_objects.map(&:id).uniq.each do |id|
      list[id] = 0
    end

    # Necha prebehnut vsetky odporucace a ich vysledky zratava dokopy
    unless config.nil? or config.recommenders_options.nil?
      config.recommenders_options.each do |r|
        r_class = Object.const_get "RecommenderSystem::#{r.recommender_name}Recommender"
        result = r_class.get_list
        result.each do |id, value|
          list[id] += value * r.weight
        end
      end
    end

    # Pridane male nahodne e, aby sa trochu rozhadzali vysledky s rovnakym skore
    list.each do |k, v|
      list[k] = v + ((Random.rand - 0.5).to_f / 100)
    end

    # Vrati vysledny list
    list.sort_by { |_, value| -value }.to_h
  end

  end
end