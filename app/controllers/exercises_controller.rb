class ExercisesController < ApplicationController
  load_and_authorize_resource
  def show
    @setup= Setup.take
    @exercise = Exercise.find_by_id(params[:id])
  end

  def update
    if(!@exercise.real_start)
      @exercise.real_start = Time.current
    else
      @exercise.real_end = Time.current
    end
    respond_to do |format|
      if @exercise.update(exercise_params)
        format.html { redirect_to @exercise}
        format.json { head :no_content }
      end
    end
  end

  private

  def exercise_params
    params.require(:exercise).permit(:start, :user_id, :week_id, :code)
  end

end
