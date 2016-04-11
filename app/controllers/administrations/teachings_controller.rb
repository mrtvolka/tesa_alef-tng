module Administrations
  class TeachingsController < ApplicationController
    authorize_resource :class => false

    # all teachings
    def index
      @exercises = Exercise.all.order(:start)
    end

    # add new teaching
    def new
      @exercise = Exercise.new
      @teachers = User.where(:role => ["teacher","administrator"]).order(:last_name, :first_name)
    end

    def create
      @teachers = User.where(:role => ["teacher","administrator"]).order(:last_name, :first_name)
      exercise_date = Setup.first.first_week_at + ((exercise_params[:week_id].to_i-1)*7).days
      @exercise = Exercise.new(exercise_params)
      @exercise.start = exercise_date + exercise_params["start(4i)"].to_i.hours + exercise_params["start(5i)"].to_i.minutes
      @exercise.end = exercise_date + exercise_params["end(4i)"].to_i.hours + exercise_params["end(5i)"].to_i.minutes
      begin
        @exercise.save!
      rescue ActiveRecord::RecordInvalid => e
        redirect_to new_administrations_teaching_path, notice: t('admin.exercises.texts.codeexists')
        return
      end
      redirect_to edit_administrations_teaching_path(@exercise), notice: t('admin.exercises.texts.created')
    end

    def edit
      @exercise = Exercise.find_by_id(params[:teaching_id])
      @teachers = User.where(:role => ["teacher","administrator"]).order(:last_name, :first_name)
      @concepts = Concept.all - @exercise.concepts
      @exercise_concepts = @exercise.concepts
      @concept = Concept.new
    end

    def update
      exercise_date = Setup.first.first_week_at + ((exercise_params[:week_id].to_i-1)*7).days
      ex_start = exercise_date + exercise_params["start(4i)"].to_i.hours + exercise_params["start(5i)"].to_i.minutes
      ex_end = exercise_date + exercise_params["end(4i)"].to_i.hours + exercise_params["end(5i)"].to_i.minutes
      @exercise = Exercise.find(params[:teaching_id])
      begin
        @exercise.update!(exercise_params)
        @exercise.update!(:start => ex_start, :end => ex_end)
      rescue ActiveRecord::RecordInvalid => e
        redirect_to edit_administrations_teaching_path(@exercise), notice: t('admin.exercises.texts.codeexists')
        return
      end
      redirect_to edit_administrations_teaching_path(@exercise), notice: t('global.texts.updated')
    end

    def destroy
      @exercise = Exercise.find(params[:id])
      @exercise.destroy!
      redirect_to administrations_teachings_path, notice: t('global.texts.deleted')
    end

    def addconcept
      exercise = Exercise.find(params[:teaching_id])
      concept = Concept.find(params[:concept][:name])
      exercise.concepts << concept
      @exercise_concepts = exercise.concepts
      @concepts = Concept.all - @exercise_concepts
      @concept = Concept.new
      respond_to do |format|
        format.js { }
      end
    end

    def deleteconcept
      exercise = Exercise.find(params[:teaching_id])
      concept = Concept.find(params[:id])
      exercise.concepts.delete(concept)
      @exercise_concepts = exercise.concepts
      @concepts = Concept.all - @exercise_concepts
      @concept = Concept.new
      respond_to do |format|
        format.js { }
      end
    end

    private

    def exercise_params
      params.require(:exercise).permit(:week_id, :user_id, :start, :end, :code, :test_length, :cooldown_time_amount)
    end

  end
end
