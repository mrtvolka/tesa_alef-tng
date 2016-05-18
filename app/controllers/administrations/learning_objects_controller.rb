module Administrations
  class LearningObjectsController < ApplicationController
    authorize_resource :class => false
    before_action :get_course, only: [:index, :new, :create]

    # Specifies action for showing list of available learning objects
    # get 'administrations/learning_objects'
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

    # Specifies action for creating new learning object
    # get 'administrations/learning_object/new'
    def new
      @learning_object = LearningObject.new
    end

    # Specifies action for saving created learning object
    # post 'administrations/learning_object/:learning_object_id/create'
    # rescues invalid records - properties not filled in correctly
    def create
      begin
        @learning_object = @course.learning_objects.new(learning_object_params)
        @learning_object.save!
        redirect_to edit_administrations_learning_object_path(@learning_object), notice: t('.notice.created')
      rescue ActiveRecord::RecordInvalid
        flash[:notice] = t('global.texts.please_fill_in')
        render 'new'
      end
    end

    # Specifies action for editing existing learning object
    # get 'administrations/learning_objects/:learning_object_id/edit'
    def edit
      @learning_object = LearningObject.find_by_id(params[:learning_object_id])
      @answers = @learning_object.answers
    end

    # Specifies action for update of learning objects
    # patch 'administrations/learning_objects/:learning_object_id/update'
    # updates all attributes of learning object specified in learning_object_params
    # rescues problems with not filled required attributes
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

    # Specifies action for deleting learning object
    # delete 'administrations/learning_objects/:learning_object_id/destroy'
    # learning object is selected using its id in <tt>param[:id]</tt>
    def destroy
      lo = LearningObject.find(params[:id])
      lo.destroy!
      redirect_to administration_learning_objects_path(course: lo.course_id), notice: t('.notice.deleted')
    end


    # Specifies action for importing questions from csv file and images uploaded using zip
    # post 'import_question_csv'
    # opens zip and imports question using import tasks
    # <tt>params[:test_data]</tt> - zip file containing subfolder img with images and one csv
    def csv_question_import
      csv_filepath= ""
      filepath= Array.new
      Zip::File.open(params[:test_data].path) do |zip_file|
        # Handle entries one by one
        zip_file.each do |entry|
          # Extract to file/directory/symlink
          if entry.name.end_with? '.png'
            folder= "img"
            filepath << Rails.root.join('img',entry.name)
          elsif entry.name.end_with? '.csv'
            folder= "tmp"
            csv_filepath = Rails.root.join('tmp',entry.name)
          end
          entry.extract("#{folder}/#{entry.name}")
        end
      end


      str = %x(rake tesa:data:import_tests[#{csv_filepath},img])

      filepath.each do |file|
        File.delete(file)
      end
      File.delete(csv_filepath)

      File.open(Rails.root.join('tmp','output.txt'), 'wb') do |file|
        file.write(str)
      end

      send_file Rails.root.join('tmp', 'output.txt'), :type=>"application/txt", :x_sendfile=>true
      flash[:notice]= "Otázky boli úspešne nahraté"
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