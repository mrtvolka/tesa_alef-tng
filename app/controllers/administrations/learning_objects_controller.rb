module Administrations
  class LearningObjectsController < ApplicationController
    authorize_resource :class => false
    before_action :get_course, only: [:index, :new, :create]

    def index
      @questions = @course.learning_objects.all

      feedback_new_count = Feedback.where.not(learning_object_id: nil).count
      feedback_all_aggs = Feedback.select("learning_object_id").group(:learning_object_id).count
      feedback_new_aggs = feedback_new_count > 0 ? Feedback.select("learning_object_id").group(:learning_object_id).count : {}
      @feedbacks = {
          all_aggs: feedback_all_aggs,
          new_aggs: feedback_new_aggs,
          new_count: feedback_new_count
      }
    end

    # Vytvorenie novej otazky.
    def new
      @learning_object = LearningObject.new
    end

    # Ulozenie novej otazky.
    def create
      begin
        @learning_object = @course.learning_objects.new(learning_object_params)
        @learning_object.save!
        redirect_to edit_administrations_learning_object_path(@learning_object), notice: t('admin.questions.texts.created')
      rescue ActiveRecord::RecordInvalid
        flash[:notice] = t('global.texts.please_fill_in')
        flash[:notice] = t('global.texts.please_fill_in')
        render 'new'
      end
    end

    # Editacia otazky.
    def edit
      @learning_object = LearningObject.find_by_id(params[:learning_object_id])
      @answers = @learning_object.answers
    end

    def update
      begin
        @learning_object = LearningObject.find(params[:learning_object_id])
        @learning_object.update!(learning_object_params)
        redirect_to edit_administrations_learning_object_path(@learning_object), notice: t('global.texts.updated')
      rescue ActiveRecord::RecordInvalid
        flash[:notice] = t('global.texts.please_fill_in')
        render 'edit'
      end
    end

    def destroy
      lo = LearningObject.find(params[:id])
      lo.destroy!
      redirect_to administration_learning_objects_path(course: lo.course_id), notice: t('admin.questions.texts.deleted')
    end

    private
    def get_course
      begin
        @course = Course.find(params[:course])
      rescue ActiveRecord::RecordNotFound
        redirect_to administration_path
      end
    end

    def learning_object_params
      params.require(:learning_object).permit(:lo_id, :question_text, :type, :difficulty)
    end
  end
end