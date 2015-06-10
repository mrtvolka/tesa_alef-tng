module RecommenderSystem
class AlphabeticalRecommender < RecommenderSystem::Recommender
  def self.get_list

    # Toto nefunguje dobre s diakritikou
    # Cely tento recommender je vsak len na testovanie, takze nemusi fungovat na 100%
    los = learning_objects.sort_by {|x| x.lo_id}

    list = Hash.new
    i = 0
    los.each do |lo|
      list[lo.id] = i
      i += 1
    end

    normalize list
  end
end
end