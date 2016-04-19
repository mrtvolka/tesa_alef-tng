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
      if(!@exercise.real_start)
        @exercise.real_start = Time.current
      elsif(!@exercise.real_end)
        @exercise.real_end = Time.current
      else
        @exercise.real_end = nil
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
      flash[:notice] = "Žiadne odpovede na export!"
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
        format.html { redirect_to exercise_options_path(@exercise), notice: t('admin.teaching.texts.updated')}
        format.json { head :no_content }
      end
    end
  end

  private

  def exercise_params
    params.require(:exercise).permit(:start, :user_id, :week_id, :code)
  end
end
