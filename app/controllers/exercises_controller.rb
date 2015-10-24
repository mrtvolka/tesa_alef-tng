class ExercisesController < ApplicationController
  load_and_authorize_resource
  def show
    @setup= Setup.take
    @exercise = Exercise.find_by_id(params[:id])
  end

  def update
    respond_to do |format|
      if @exercise.update(exercise_params)
        format.html { redirect_to @exercise}
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @exercise.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def exercise_params
    params.require(:exercise).permit(:start, :end, :test_started, :user_id, :week_id, :code)
  end

end
