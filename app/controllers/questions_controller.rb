class QuestionsController < ApplicationController
  authorize_resource :class => false , :only => [:submit_test,:show_test,:access_answers, :show_answers]
  def show
    @user = current_user
    user_id = @user.id

    @question = LearningObject.find(params[:id])
    rel = @question.seen_by_user(user_id)
    gon.userVisitedLoRelationId = rel.id
    @next_question = @question.next(params[:week_number])
    @previous_question = @question.previous(params[:week_number])

    @answers = @question.answers
    @relations = UserToLoRelation.where(learning_object_id: params[:id], user_id: user_id, exercise_id: nil).group('type').count

    if @user.show_solutions
      UserViewedSolutionLoRelation.create(user_id: user_id, learning_object_id: params[:id], setup_id: 1, )
      solution = @question.get_solution(current_user.id)
      gon.show_solutions = TRUE
      gon.solution = solution
    end

    @feedbacks = @question.feedbacks.includes(:user)
  end

  def evaluate

    unless ["SingleChoiceQuestion","MultiChoiceQuestion","EvaluatorQuestion"].include? params[:type]
      # Kontrola ci zasielany type je z triedy LO
      render nothing: true
      return false
    end

    lo_class = Object.const_get params[:type]
    lo = lo_class.find(params[:id])
    @solution = lo.get_solution(current_user.id)

    @user = current_user
    user_id = @user.id
    setup_id = 1

    rel = UserToLoRelation.new(setup_id: setup_id, user_id: user_id)

    if params[:commit] == 'send_answer'
      result = lo.right_answer? params[:answer], @solution
      @eval = true # informacie pre js odpoved
      rel.interaction = params[:answer]
    end

    rel.type = 'UserDidntKnowLoRelation' if params[:commit] == 'dont_know'
    rel.type = 'UserSolvedLoRelation' if params[:commit] == 'send_answer' and result
    rel.type = 'UserFailedLoRelation' if params[:commit] == 'send_answer' and not result

    lo.user_to_lo_relations << rel

  end

  def show_image
    lo = LearningObject.find(params[:id])
    send_data lo.image, :type => 'image/png', :disposition => 'inline'
  end

  def log_time
    unless params[:id].nil?
      rel = UserVisitedLoRelation.find(params[:id])
      if not rel.nil? and rel.user_id == current_user.id
        rel.update interaction: params[:time]
      end
    end
    render nothing: true
  end

  def next
    setup = Setup.take
    week = setup.weeks.find_by_number(params[:week_number])
    RecommenderSystem::Recommender.setup(current_user.id,week.id)
    best = RecommenderSystem::HybridRecommender.new.get_best
    los = LearningObject.find(best[0])
    redirect_to action: "show", id: los.url_name
  end

  #
  # Testing
  #
  def show_test
    @setup = Setup.take
    exercise = Exercise.find_by_code(params[:exercise_code])
    if exercise.nil? || exercise.real_start.nil? ||!exercise.real_end.nil?
      redirect_to root_path
      flash[:notice] = "Test nie je dostupný"
      return
    end

    if Exercise.find_by_code(params[:exercise_code]).user_to_lo_relations.where(user_id: current_user.id).exists?
      redirect_to root_path
      flash[:notice] = "Test je možné písať len raz!"
      return
    end

    @week = exercise.week
    @setup= Setup.take

    learning_objects = @week.learning_objects.all.distinct
    RecommenderSystem::TesaSimpleRecommender.setup(current_user,@week.id,params[:exercise_code])
    recommendations = RecommenderSystem::TesaSimpleRecommender.new.get_list

    @sorted_los = Array.new
    recommendations.each do |key, value|
      @sorted_los << learning_objects.find {|l| l.id == key}
    end
  end

  def submit_test
    params[:questions].each do |key, val|
      lo= LearningObject.find(key)
      rel = UserToLoRelation.new(setup_id: Setup.take.id,
                                 user_id: current_user.id,
                                 exercise_id: Exercise.find_by_code(params[:exercise_code]).id)

      if params[:questions][key][:type]!= 'OpenQuestion'
        solution = lo.get_solution(current_user.id)
        result = lo.right_answer? params[:questions][key][:answer], solution

        rel.interaction = params[:questions][key][:answer]
        rel.type = result ? 'UserSolvedLoRelation' : 'UserFailedLoRelation'
      elsif params[:questions][key][:type]== 'OpenQuestion'
            rel.submitted_text= params[:questions][key][:submitted_text]
            rel.type =  'UserSubmittedLoRelation'
           elsif(params[:questions][key][:type]== 'PhotoQuestion')
                  #TODO
                end
      lo.user_to_lo_relations << rel
    end

    render :js => "window.location = '#{weeks_path}'"
    flash[:notice] = "Test bol odovzdaný"
  end

  def check_code
    @exercise = Exercise.new(exercise_code_param)
    @exercise = Exercise.find_by_code(@exercise.code)
    if(@exercise.nil?)
      redirect_to :root
      flash[:notice] = "Nesprávny kód!"
    elsif(!@exercise.real_end.nil?)
      # TODO: working with submitted tests
      redirect_to :root
      flash[:notice] = "Test už bol ukončený!"
    else
      @exercise = Exercise.find_by_code(@exercise.code)
      redirect_to :action => "show_test",  :exercise_code => @exercise.code
    end
  end

  def show_answers
    week= Week.find_by_number(params[:week_number])
    if (week.nil?)
      redirect_to :back
      flash[:notice] = "Neznámy týždeň!"
      return
    end
    exercise= Exercise.joins('JOIN user_to_lo_relations u ON exercises.id=u.exercise_id').where("week_id= ? AND u.user_id = ?",week.id, current_user.id).take
    if (exercise.nil?)
      redirect_to :back
      flash[:notice] = "Neznáme cvičenie!"
      return
    end

    if exercise.nil? || exercise.real_start.nil? ||exercise.real_end.nil?
      redirect_to :back
      flash[:notice] = "Test ešte nebol ukončený!"
      return
    end

    if (((exercise.real_end+exercise.cooldown_time_amount*60) <=> Time.now)!=-1)
      redirect_to :back
      flash[:notice] = "Odpovede ešte nie sú dostupné!"
      return
    end

    @week = exercise.week
    @setup= Setup.take

    learning_objects = @week.learning_objects.all.distinct
    RecommenderSystem::TesaSimpleRecommender.setup(current_user,@week.id,exercise.code)
    recommendations = RecommenderSystem::TesaSimpleRecommender.new.get_list

    @sorted_los = Array.new
    recommendations.each do |key, value|
      @sorted_los << learning_objects.find {|l| l.id == key}
    end
    @student_answers= UserToLoRelation.where("user_id = ? AND exercise_id = ?", current_user.id, exercise.id)
  end

  private
    def exercise_code_param
      params.require(:exercise).permit(:code)
    end

end
