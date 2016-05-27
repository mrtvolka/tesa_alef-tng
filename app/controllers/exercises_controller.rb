class ExercisesController < ApplicationController
  load_and_authorize_resource

  # Specifies action for exercise show page
  # get 'exercises/show'
  # shows exercise with id from params[:id]
  def show
    gon.exercise_id = params[:id]
    @setup= Setup.take
    @exercise = Exercise.find_by_id(params[:id])
    @counter = UserToLoRelation.where(exercise_id: params[:id]).where.not(type: 'UserVisitedLoRelation').group(:user_id).count.count
    @entry_counter = UserVisitedLoRelation.where(exercise_id: params[:id]).group(:user_id).count.count
  end

  # Specifies action for ajax call rereshing counter and test timer
  # get 'exercises/event/refresh'
  # called from view's js
  def refresh
    unless params[:id].blank?
      @counter = UserToLoRelation.where(exercise_id: params[:id]).where.not(type: 'UserVisitedLoRelation').group(:user_id).count.count
      @entry_counter = UserVisitedLoRelation.where(exercise_id: params[:id]).group(:user_id).count.count
      respond_to do |format|
        format.js
      end
    end
  end

  # Specifies action for exercise update
  # get 'exercises/edit'
  # called from different actions in exercise show view
  # <tt>params[:stats]</tt> - if defined redirects to statistic page
  # <tt>params[:results]<tt> - if defined redirects to exercise results page
  # when any params posted in request - change state of exercise
  # if test not yet started: start test
  # if test started: stop test
  def update
    if(params[:stats])
      redirect_to statistics_path(id: @exercise.id)
    elsif (params[:results])
      redirect_to results_path(id: @exercise.id)
    elsif (params[:answers])
      redirect_to answers_path(id: @exercise.id, format: "csv")
    else
      if(!@exercise.real_start)   # start test first time
        @exercise.real_start = Time.current

        create_qr_code
      elsif(!@exercise.real_end) # end test
        @exercise.real_end = Time.current
        ScoringSystem.const_get(Setup.take.scoring_type).doScoringForExercise(@exercise.id)
        FileUtils.rm('./public/assets/qrcode' + @exercise.id.to_s + '.png')
      else # start test again
        @exercise.real_end = nil
        create_qr_code
      end
      respond_to do |format|
        if @exercise.save
          format.html { redirect_to @exercise}
          format.json { head :no_content }
        end
      end
    end

  end

  # Specifies action for exercise results
  # get  'exercise/results'
  # shows results for exercise with id from <tt>params[:id]</tt>
  def results
    @setup= Setup.take
    @exercise = Exercise.find_by_id(params[:id])
  end

  # Specifies action for exporting answers to csv
  # get 'exercises/:id/answers'
  # <tt>param[:id]</tt> - id of exercise
  # responds with csv file if any answers exist
  def answers
    @answers = UserToLoRelation.where(:exercise_id => params[:id]).where.not(type: 'UserVisitedLoRelation')
    if !@answers.any?
      redirect_to :back
      flash[:notice] = t('global.exercise.no_answers_for_export')
    else
      teacher = User.find_by_id(@exercise.user_id).login
      filename = "Vysledky_pre_#{@exercise.id.to_s}_#{teacher}.csv"
      respond_to do |format|
          format.html
          format.csv { send_data @answers.to_csv, filename: filename }
      end
    end
  end

  # Specifies action for options of exercise
  # get 'exercise/:id/options'
  # used for setting exercise times: test length and cooldown time
  def options
    @exercise = Exercise.find_by_id(params[:id])
  end

  # Specifies action for saving updated options for exercise
  # post 'exercice/:id/update_options'
  # updates options from params
  # <tt>params[:exercise][:options]</tt> - params
  def update_options
    @exercise = Exercise.find_by_id(params[:id])
    options = @exercise.options
    if options.nil?
      options = Hash.new
    end
    unless params[:exercise][:options]['cooldown_time'].nil?
      options['cooldown_time'] = params[:exercise][:options]['cooldown_time']
    end
    unless params[:exercise][:options]['test_length'].nil?
      options['test_length'] = params[:exercise][:options]['test_length']
    end
    respond_to do |format|
      if @exercise.update(options)
        format.html { redirect_to exercise_options_path(@exercise), notice: t('.notice.updated')}
        format.json { head :no_content }
      end
    end
  end

  private

  # params used as helper in some controller questions
  def exercise_params
    params.require(:exercise).permit(:start, :user_id, :week_id, :code)
  end

  # Specifies creation of QR code in assets folder
  # generates qr code with url for accessing exercise test
  def create_qr_code
    qrcode = RQRCode::QRCode.new((url_for :action => 'show_test', :controller => 'questions', :exercise_code => @exercise.code , :only_path => false))
    qrcode.as_png(
        resize_gte_to: false,
        resize_exactly_to: false,
        fill: 'white',
        color: 'black',
        size: 900,
        border_modules: 4,
        module_px_size: 6,
        file: './public/assets/qrcode' + @exercise.id.to_s + '.png')
  end
end
