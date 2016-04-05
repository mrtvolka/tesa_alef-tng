class ExercisesController < ApplicationController
  load_and_authorize_resource
  def show
    gon.exercise_id = params[:id]
    @setup= Setup.take
    @exercise = Exercise.find_by_id(params[:id])
    qrcode = RQRCode::QRCode.new((url_for :action => 'show_test', :controller => 'questions', :exercise_code => @exercise.code , :only_path => false))
    png = qrcode.as_png(
        resize_gte_to: false,
        resize_exactly_to: false,
        fill: 'white',
        color: 'black',
        size: 900,
        border_modules: 4,
        module_px_size: 6,
        file: './app/assets/images/qrcode.png'
    )
    if (!params[:real_start].nil?)
      @exercise.real_start= Time.current
      @exercise.save!
    end
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
    else
      if(!@exercise.real_start)
        @exercise.real_start = Time.current
      elsif(!@exercise.real_end)
        @exercise.real_end = Time.current
      else
        @exercise.real_end = nil
      end
      respond_to do |format|
        if @exercise.update(exercise_params)
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

  private

  def exercise_params
    params.require(:exercise).permit(:start, :user_id, :week_id, :code)
  end

end
