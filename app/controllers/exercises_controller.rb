class ExercisesController < ApplicationController
  load_and_authorize_resource
  def show
    gon.exercise_id = params[:id]
    @setup= Setup.take
    @exercise = Exercise.find_by_id(params[:id])
  end

  def refresh
    unless params[:id].blank?
      @counter = UserToLoRelation.where(exercise_id: params[:id]).group(:user_id).count.count
      respond_to do |format|
        format.js
      end
    end
  end

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

  def results
    @setup= Setup.take
    @exercise = Exercise.find_by_id(params[:id])
  end

  def answers
    @answers = UserToLoRelation.where(:exercise_id => params[:id])
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

  def options
    @exercise = Exercise.find_by_id(params[:id])
  end

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

  def exercise_params
    params.require(:exercise).permit(:start, :user_id, :week_id, :code)
  end

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
