module Administrations
  class TeachingsController < ApplicationController
    authorize_resource :class => false

    def index
      @exercises = Exercise.all.order(:start)
    end

    def new
      @exercise = Exercise.new
      @teachers = User.where(:role => ["teacher","administrator"]).order(:last_name, :first_name)
    end

    def create
      @exercise = Exercise.new(exercise_params)
      @exercise.generatecode
      @exercise.save!
      redirect_to edit_administrations_teaching_path(@exercise), notice: t('.notice.created')
    end

    def edit
      @exercise = Exercise.find_by_id(params[:teaching_id])
      @teachers = User.where(:role => ["teacher","administrator"]).order(:last_name, :first_name)
    end

    def update
      @exercise = Exercise.find(params[:teaching_id])
      @exercise.change_concepts(params[:exercise][:concepts])
      begin
        @exercise.update!(exercise_params)
      rescue ActiveRecord::RecordInvalid => e
        redirect_to edit_administrations_teaching_path(@exercise), notice: t('.notice.codeexists')
        return
      end
      redirect_to edit_administrations_teaching_path(@exercise), notice: t('.notice.updated')
    end

    def destroy
      @exercise = Exercise.find(params[:id])
      @exercise.destroy!
      redirect_to administrations_teachings_path, notice: t('.notice.deleted')
    end

    private

    def exercise_params
      params.require(:exercise).permit(:week_id, :user_id, :start, :end, :code,
                                       options: [:exercise_concepts, :week_concepts, :cooldown_time, :test_length, ])
    end

  end
end
