module Administrations
  class TeachingsController < ApplicationController
    authorize_resource :class => false

    # Specifies action for listing all avialable terms
    # get 'adminitrations/teachings/:teaching_id/index'
    def index
      @exercises = Exercise.all.order(:start)
    end

    # Specifies action for new teaching
    # get 'administrations/teachings/:teaching_id/new'
    def new
      @exercise = Exercise.new
      @teachers = User.where(:role => ["teacher","administrator"]).order(:last_name, :first_name)
    end

    # Specifies action for saving created teaching to database
    # post 'administrations/teachings/:teaching_id/create'
    # new teaching is created using exercise_params
    # test access code is generated programmatically
    def create
      @exercise = Exercise.new(exercise_params)
      @exercise.generatecode
      @exercise.save!
      redirect_to edit_administrations_teaching_path(@exercise), notice: t('.notice.created')
    end

    # Specifies action for editing existing teaching
    # get 'administrations/teachings/:teaching_id/edit'
    # <tt>@teachers</tt> are used for selecting teaching leading in select area
    def edit
      @exercise = Exercise.find_by_id(params[:teaching_id])
      @teachers = User.where(:role => ["teacher","administrator"]).order(:last_name, :first_name)
    end

    # Specifies action for saving edited teching with its updated attributes
    # patch 'administrations/teaching/:teaching_id/update'
    # uses <tt>params[:teaching_id]</tt> - teaching attributes
    # <tt>params[:exercise][:concepts]</tt> - used for creating associated records of teaching and concepts
    # rescues problems with updating teching using occupied acces code
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

    # Specifies action for deleting teaching
    # delete 'administrations/teachings/:teaching_id/destroy'
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
