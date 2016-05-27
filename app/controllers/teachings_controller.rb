class TeachingsController < ApplicationController
  authorize_resource :class => false

  # Specifies action for teachers main page
  # get 'teaching'
  def show
    @setup= Setup.take
    @actual_week= Week.get_actual
    if current_user.role == 'administrator'
      @exercises= Exercise.all.order(:week_id, :start)
    else
      @exercises= Exercise.all.where(user_id: current_user.id).order(:week_id, :start)
    end
  end

  # Defines action for list of questions
  # get 'teaching/questions'
  def list_questions
    @setup= Setup.take
    @questions= LearningObject.where("is_test_question= true").order(id: :asc)
  end

  # Action for list of all answers for specified question
  # get 'teaching/:id/answers'
  #   <tt>params[:id]</tt> => id of specified question
  def list_answers
    @setup= Setup.take
    @question= LearningObject.find(params[:id])
    if current_user.administrator?
      @relations= @question.user_to_lo_relations.where.not(type: 'UserVisitedLoRelation').joins('JOIN users u ON user_id= u.id').order('type ASC,exercise_id DESC,u.last_name ASC, u.first_name ASC')
    else
      @relations= @question.user_to_lo_relations.where.not(type: 'UserVisitedLoRelation').joins('JOIN users u ON user_id= u.id').where("exercise_id IN (?)", Exercise.where("user_id = (?)", current_user.id).select(:id)).order('type ASC,exercise_id ASC,u.last_name ASC,u.first_name ASC')
    end
    @next_question= LearningObject.where('is_test_question= true AND (id > (?))',params[:id]).order(id: :asc).first
    @previous_question= LearningObject.where('is_test_question= true AND (id < (?))',params[:id]).order(id: :asc).last
  end

  # Specifies action for posting regexp and subsequent evaluation of open questions
  # post 'teaching/:id/submit_regexp'
  #   <tt>params[:id]</tt> => id of specified question
  #   <tt>params[:regexp]</tt> => string with regular expression
  def submit_regexp
    @question= LearningObject.find(params[:id])

    regexp= /#{params[:regexp]}/
    @question.user_to_lo_relations.each do |relation|
      result=regexp.match(relation.submitted_text)
      if(result.nil?)
        relation.type= "UserFailedLoRelation"
      else
        relation.type= "UserSolvedLoRelation"
      end
      relation.save!
    end

    redirect_to :back
  end

  # Defines action to admit points to student answer
  # post 'teaching/:id/admit_answer'
  #   <tt>params[:id]</tt> => id of specified question
  #   <tt>params[:student_answer_id]</tt> => id of student answer
  #   <tt>params[:student_answer_points]<//tt> => points to give
  def admit_student_answer
    @question= LearningObject.find(params[:id])
    rel=@question.user_to_lo_relations.find(params[:student_answer_id])
    rel.points= params[:student_answer_points]
    rel.save!

    redirect_to :back
  end

  # Specifies action for statistics of a single exercise
  # get 'exercise/statistics'
  #   <tt>params[:id]</tt> => exercise id
  def statistics
    @setup = Setup.take
    @chart = []
    @titles = []
    @indexes = []
    @images = []
    @week = Exercise.find(params[:id]).week
    i = 0
    submitted_answer = UserToLoRelation.select(:learning_object_id).where("exercise_id = (?)", params[:id]).group(:learning_object_id).where.not(type: 'UserVisitedLoRelation')
    submitted_answer.each do |answer|
      questions = LearningObject.where("id = (?) AND is_test_question = TRUE", answer.learning_object_id)
      question = questions[0]
      @titles << question.question_text
      @indexes << question.id
      @images << question.image
      if question.type == 'SingleChoiceQuestion' or question.type == 'MultiChoiceQuestion'
        @chart << LazyHighCharts::HighChart.new('graph') do |f|
          answers = Answer.where(learning_object_id: question.id)
          legend = process_legend(question, answers)
          if question.type == 'SingleChoiceQuestion'
            data = process_single_choice_answers(question, legend)
          else
            data = process_multi_choice_answers(question, legend)
          end
          i+=1
          f.chart({:defaultSeriesType=>"bar"})
          f.colors(["#D64541"])
          f.xAxis(:categories => extract_names(legend), :labels => {:style => ""}) # clear style
          f.series(:name => "Počet odpovedí", :yAxis => 0, :data => data)
          f.yAxis [ {:min => 0, :tickInterval=> 1, :title => nil},]
          f.legend(:enabled => false, :align => 'right', :verticalAlign => 'top', :y => 75, :x => -50, :layout => 'vertical',)
        end
      elsif question.type == 'OpenQuestion'
        @chart << process_open_answers(question)
      end
    end
  end

  def process_legend(question, answers)
    legend = Hash.new
    answers.each do |answer|
      legend[answer.id] = answer['answer_text']
    end
    return legend
  end

  def extract_names(legend)
    names = []
    legend.each do |element|
      names << element[1]
    end
    names << "bez odpovede"
    return names
  end

  def process_single_choice_answers(question, legend)
    result = Hash.new
    legend.each do |key|
      result[key[0]] =  0 ;
    end
    no_answer = 0
    answers = UserToLoRelation.where(learning_object_id: question.id, exercise_id: params[:id]).where.not(type: 'UserVisitedLoRelation')
    answers.each do |answer|
      if answer.interaction.nil?
        no_answer += 1
      else
        result[answer.interaction.to_i] +=1
      end
    end
    values = []
    result.each do |element|
      values <<  element[1] ;
    end
    values << no_answer
    return values
  end

  def process_multi_choice_answers(question, legend)
    result = Hash.new
    legend.each do |key|
      result[key[0]] =  0 ;
    end
    no_answer = 0
    answers = UserToLoRelation.where(learning_object_id: question.id, exercise_id: params[:id]).where.not(type: 'UserVisitedLoRelation')
    answers.each do |answer|
      if answer.interaction.nil?
        no_answer += 1
      else
        choice = JSON(answer.interaction.gsub('=>', ':'));
        choice.each do |i|
          result[i[0].to_i] +=1
        end
      end
    end
    values = []
    result.each do |element|
      values <<  element[1] ;
    end
    values << no_answer
    return values
  end

  def process_open_answers(question)
    result = []
    result[0] = question.question_text
    result[1] = Hash.new
    no_answer = 0
    answers = UserToLoRelation.where(learning_object_id: question.id, exercise_id: params[:id]).where.not(type: 'UserVisitedLoRelation')
    answers.each do |answer|
      if answer.submitted_text.nil?
        no_answer += 1
      else
        choice = ActiveSupport::Inflector.transliterate(answer.submitted_text).downcase.gsub(/\W/, ' ').strip
        if result[1][choice].nil?
          result[1][choice] = 1
        else
          result[1][choice] += 1
        end
      end
    end
    result[1] = result[1].sort_by {|k,v| v}.reverse
    return result
  end
end
