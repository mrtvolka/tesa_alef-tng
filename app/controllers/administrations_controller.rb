class AdministrationsController < ApplicationController
  authorize_resource :class => false

  # Specifies action for administration setting main page
  # get 'admin'
  def index
    @setups = Setup.all
    @courses = Course.all
  end

  # Defines action for setup setting in administration
  # get 'admin/setup_config/:setup_id'
  #   <tt>params[:setup_id]</tt> => id of setup
  def setup_config
    @setup = Setup.find(params[:setup_id])
    @concepts = @setup.course.concepts.includes(:weeks).order(:pseudo, :name)
    @weeks = @setup.weeks.order(:number)
  end

  # Action that implements submitting new settings for specified setup
  # post 'admin/setup_config/:setup_id/setup_attributes'
  #   <tt>params[:setup_id]</tt> => id of setup
  #   <tt>params[:setup]</tt> => hash containing following attributes
  #     <tt>params[:setup][:week_count]</tt> => number of weeks in semester
  #     <tt>params[:setup][:first_week_at]</tt> => date of first week of semester
  #     <tt>params[:setup][:show_all]</tt> => not implemented
  def setup_config_attributes
    @setup = Setup.find(params[:setup_id])
    weeks = @setup.weeks
    week_count = params[:setup][:week_count].to_i
    ActiveRecord::Base.transaction do
      if week_count >= @setup.week_count
        (@setup.week_count+1..week_count).each do |w|
          Week.create!(setup_id: @setup.id, number: w)
        end
      else
          weeks.where(number: week_count+1..@setup.week_count).destroy_all
      end
      @setup.update(params.require(:setup).permit(:week_count, :first_week_at, :show_all))
    end
    redirect_to setup_config_path, flash[:notice] = t('global.admin.saved')
  end

  # Specifies submitting new concept to weeks relations
  # post 'admin/setup_config/:setup_id/setup_relations'
  #   <tt>params[:setup_id]</tt> => id of setup
  #   <tt>params[:relations]</tt> => hash cotaining set of
  #     pairs concept-weeks for which relationships have to be saved
  def setup_config_relations
    relations = params[:relations]
    relations.each do |concept, weeks|
      c = Concept.find(concept)
      w = Setup.find(params[:setup_id]).weeks.find(weeks.keys)
      c.weeks = w
    end
    redirect_to setup_config_path, flash[:notice] = t('global.admin.saved')
  end

  # Defines action for downloading statistics
  # get 'admin/setup_config/:setup_id/download_statistics'
  #   <tt>params[:setup_id]</tt> => id of setup
  # returns file containing statistics
  def download_statistics
    @setup = Setup.find(params[:_setup_id])
    filepath_full = @setup.compute_stats()
    send_file filepath_full
  end

  # Specifies action for course settings page
  # get 'admin/question_concept_config/:course_id'
  #   <tt>params[:course_id]</tt> => id of course
  def question_concept_config
    @course = Course.find(params[:course_id])
    @questions = @course.learning_objects.includes(:answers,:concepts).all
    gon.concepts = @course.concepts.pluck(:name)
  end

  def delete_question_concept
    question = LearningObject.find(params[:question_id])
    Concept.find(params[:concept_id]).learning_objects.delete(question)
  end

  def add_question_concept
    if params[:concept_name].empty?
      render nothing: true
      return
    end

    @concept = Course.find(params[:course_id]).concepts.find_by_name(params[:concept_name])
    @question = LearningObject.find(params[:question_id])

    if (not(@concept.nil?)) && (not(@question.concepts.include? @concept))
      @question.concepts << @concept
      return
    end
    render nothing: true
  end

end
