class TeachingsController < ApplicationController
  authorize_resource :class => false
  def show
    @setup= Setup.take

    #@exercises= Exercise.all.order(week_id: :asc)
    @actual_week= Week.get_actual
    if current_user.role == 'administrator'
      @exercises= Exercise.all.order(:week_id, :start)
    else
      @exercises= Exercise.all.where(user_id: current_user.id).order(:week_id, :start)
    end
  end

  def statistics
    @chart = []

    i = 0
    submitted_answer = UserToLoRelation.select(:learning_object_id).where("exercise_id = ?", params[:id]).group(:learning_object_id)
    submitted_answer.each do |answer|
      questions = LearningObject.where("id = ? AND is_test_question = TRUE", answer.learning_object_id)
      question = questions[0]
      if question.type == 'SingleChoiceQuestion' or question.type == 'MultiChoiceQuestion'
        @chart << LazyHighCharts::HighChart.new('graph') do |f|
          answers = Answer.where(learning_object_id: question.id )
          legend = process_legend(question, answers)
          i+=1
          f.title(:text => question.question_text, :order => i)
          f.chart({:defaultSeriesType=>"bar"})
          f.colors(["#D64541"])
          f.xAxis(:categories => extract_names(legend)) # , :labels => {:style => ""} # clear style
          f.series(:name => "Počet odpovedí", :yAxis => 0, :data => process_choice_answers(question, legend))
          f.yAxis [ {:min => 0, :tickInterval=> 1, :title => nil},]
          f.legend(:enabled => false, :align => 'right', :verticalAlign => 'top', :y => 75, :x => -50, :layout => 'vertical',)
        end
      else
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
    return names
  end

  def process_choice_answers(question, legend)
    result = Hash.new
    legend.each do |key|
      result[key[0]] =  0 ;
    end

    answers = UserToLoRelation.where(learning_object_id: question.id )
    answers.each do |answer|
      choice = JSON(answer.interaction.gsub('=>', ':'));
      choice.each do |i|
        result[i[0].to_i] +=1
      end
    end
    values = []
    result.each do |element|
      values <<  element[1] ;
    end

    return values
  end

  def process_open_answers(question)
    result = []
    result[0] = question.question_text
    result[1] = Hash.new

    answers = UserToLoRelation.where(learning_object_id: question.id )
    answers.each do |answer|
      choice = ActiveSupport::Inflector.transliterate(answer.submitted_text).downcase.gsub(/\W/, ' ').strip
      if result[1][choice].nil?
        result[1][choice] = 1
      else
        result[1][choice] += 1
      end
    end
    result[1] = result[1].sort_by {|k,v| v}.reverse
    return result
  end
end
