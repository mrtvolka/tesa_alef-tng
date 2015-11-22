require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'pandoc-ruby'
require 'csv'

namespace :tesa do
  namespace :data do

    # set all possible answers (a,b,c,d,e) correct_answer field
    def get_correct_answers(right_answers)
      answers =  [false, false, false, false, false]
      if !right_answers.nil?
        correct_answers = right_answers.split(' ')
        correct_answers.each do |ca|
          if ca=='a'
            answers[0] = true
          elsif ca=='b'
            answers[1] = true
          elsif ca=='c'
            answers[2] = true
          elsif ca=='d'
            answers[3] = true
          else
            answers[4] = true
          end
        end
      end
      return answers
    end

    # TODO: recreate questions text | character
    def import_testquestions(file)
      CSV.read(file, :headers => true, :col_sep=>';').each do |row|

        difficulty = "unknown difficulty"
        topic = row['tema']
        name = row['id']
        question_text = row['otazka']
        question_type = row['typ']
        answers = [row['odpoved_a'], row['odpoved_b'], row['odpoved_c'], row['odpoved_d'], row['odpoved_e']]
        right_answers = row['spravne']

        if question_type == '1'
          question_type = 'MultiChoiceQuestion'
        else
          question_type = 'OpenQuestion'
        end

        # create new learning object
        lo = LearningObject.create!(course_id: Course.first, difficulty: difficulty, is_test_question: true,
                                    question_text: question_text, lo_id: name, type: question_type)

        # link new learning object with concept and concept with week
        week = Week.find_or_create_by(number: topic) do |w|
          w.setup = Setup.first
        end
        concept = Concept.find_or_create_by(name: topic) do |c|
          c.course = Course.first
          c.pseudo = false
        end
        concept.weeks << week unless concept.weeks.include? week
        lo.link_concept(concept)
        # add answers for learning object with choices
        if lo.type == "MultiChoiceQuestion"
          correct_answers = get_correct_answers(right_answers)
          answer_index = 0
          answers.each do |answer|
            if !answer.nil?
              Answer.create!(learning_object_id: lo.id, answer_text: answer, is_correct: correct_answers[answer_index])
            end
            answer_index+=1
          end
        end
      end
    end


    # import questions from CSV test questions file
    # run:
    #    rake tesa:data:import_tests[filename.csv]
    task :import_tests, [:tests_csv] => :environment do |t, args|
      import_testquestions(args.tests_csv)
    end
  end
end