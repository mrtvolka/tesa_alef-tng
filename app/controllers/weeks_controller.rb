class WeeksController < ApplicationController
  def show
    @setup = Setup.take
    @week = @setup.weeks.find_by_number(params[:week_number])
    @next_week = @week.next
    @previous_week = @week.previous

    learning_objects = @week.learning_objects.all.distinct
    @results = UserToLoRelation.get_results(current_user.id,@week.id)

    RecommenderSystem::Recommender.setup(current_user.id,@week.id)
    recommendations = RecommenderSystem::HybridRecommender.new.get_list

    @sorted_los = Array.new
    recommendations.each do |key, value|
      @sorted_los << learning_objects.find {|l| l.id == key}
    end

    @user = current_user
  end

  def list
    @setup = Setup.take
    @weeks = @setup.weeks.order(number: :desc)
    @user = current_user
  end

  def test_list
    @setup = Setup.take
    @weeks = @setup.weeks.order(number: :desc)
    @user = current_user
    exercises = Exercise.find_by_sql(["SELECT e.* FROM exercises e
                                        JOIN user_to_lo_relations u
                                        ON e.id=u.exercise_id
                                        JOIN users us
                                        ON u.user_id=us.id
                                        WHERE us.id = ?", current_user.id])
    ids = exercises.collect(&:week_id)
    @week_tests = @setup.weeks.where(id: ids).order(number: :desc)
    available_test = !Exercise.where('real_end IS NULL AND real_start < (?)',Time.current).nil?
  end

  def enter_test
    @setup = Setup.take
    @exercise = Exercise.new
  end

  def index
    @setup = Setup.take
    @weeks = @setup.weeks.order(number: :desc)
    @user = current_user
    if @user.student?
      # students options for root
      available_test = Exercise.where('real_start IS NOT NULL AND real_end IS NULL').first
      if !available_test.nil?
        @exercise = Exercise.new
        render :action => 'enter_test', :controller => 'weeks'
      else
        render :action => 'list', :controller => 'weeks'
      end
    else
      #TODO: teachers and admin options for root
      render :action => 'list', :controller => 'weeks'
    end
  end
end
