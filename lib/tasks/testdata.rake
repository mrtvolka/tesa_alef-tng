require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'pandoc-ruby'
require 'csv'

namespace :tesa do
  namespace :data do

    TESA_QUESTION_TYPES = {
        'single-choice' => 'SingleChoiceQuestion',
        'multi-choice' => 'MultiChoiceQuestion',
        'answer-validator' => 'EvaluatorQuestion',
        'complement' => 'Complement',
        'open-question' => 'OpenQuestion'
    }

    def import_difficulty(difficulty_string, learning_object)
      difficulty_levels = {
          'trivialne' => LearningObject::DIFFICULTY[:TRIVIAL],
          'lahke' => LearningObject::DIFFICULTY[:EASY],
          'stredne' => LearningObject::DIFFICULTY[:MEDIUM],
          'tazke' => LearningObject::DIFFICULTY[:HARD],
          'impossible' => LearningObject::DIFFICULTY[:IMPOSSIBLE]
      }

      difficulty = difficulty_levels[difficulty_string.andand.strip]
      unless difficulty
        puts "WARNING: '#{learning_object.external_reference}' - '#{learning_object.lo_id}' has unrecognized difficulty string: '#{difficulty_string.inspect}'"
        difficulty = LearningObject::DIFFICULTY[:UNKNOWN]
      end

      learning_object.update(difficulty: difficulty)
    end

    def import_concepts(concepts_string,learning_object,week_number)
      if concepts_string.nil? || concepts_string.empty?
        puts "WARNING: '#{learning_object.external_reference}' - '#{learning_object.lo_id}' has no concepts"
        concepts_string = Concept::DUMMY_CONCEPT_NAME
      end

      week = Week.find_or_create_by(number: week_number) do |w|
        w.setup = Setup.first
      end

      concept_names = concepts_string.split(',').map{|x| week_number + ". týždeň - " + x.strip}
      concept_names.each do |concept_name|
        #concept_name =  + concept_name
        concept = Concept.find_or_create_by(name: concept_name) do |c|
          c.course = Course.first
          c.pseudo = (concept_name == Concept::DUMMY_CONCEPT_NAME)
        end
        concept.weeks << week unless concept.weeks.include? week
        learning_object.link_concept(concept)
      end

      learning_object.concepts.delete(learning_object.concepts.where.not(name: concept_names))
    end

    def import_pictures(picture, pictures_dir, lo)
      picture = picture.split('/').last

      begin
        image = File.read(pictures_dir + '/' + picture)
        LearningObject.where(id: lo.id).update_all(image: image)
      rescue Errno::ENOENT => ex
        puts "IMAGE MISSING: #{picture}"
        raise
      end
    end

    def convert_format(source_string, is_answer = false)
      is_answer ? source_string.gsub(/<correct>|<\/correct>/,'') : source_string
    end

    def check_is_special_flag(is_special_flag)
      !is_special_flag.nil? && is_special_flag == "TRUE" ? true : false
    end

    # CSV format:
    # Title,Question,Concepts,Type,Answers,Difficulty,Picture,Is special flag,Week
    def import_tests_data(file, pictures_dir)
      CSV.read(file, :headers => true).each do |row|
        question_name = row[0]
        question_text = row[1]
        concept_names = row[2]
        question_type = TESA_QUESTION_TYPES[row[3]]
        answers = row[4]
        difficulty_text = row[5]
        picture = row[6]
        is_special = check_is_special_flag(row[7])
        week_number = row[8]

        lo = LearningObject.find_or_create_by(question_text: question_text) do |lo|
          lo.course = Course.first
        end
        lo.update( type: question_type, lo_id: question_name, question_text: question_text, is_test_question: true, is_special_question: is_special)

        # TODO import answers when updating existing LO, not only upon first creation
        # ^NOTE: answer ID should be preserved whenever possible for logged relations
        if lo.answers.empty? && question_type != 'OpenQuestion'
          answers.split(';').each do |answer|
            correct_answer = answer.include? '<correct>'
            answer_text = convert_format(answer, true)
            Answer.create!( learning_object_id: lo.id, answer_text: answer_text, is_correct: correct_answer )
          end
        end

        import_difficulty(difficulty_text, lo)
        import_concepts(concept_names, lo, week_number)
        import_pictures(picture, pictures_dir, lo) if picture
      end
    end

    task :import_tests, [:tests_questions_csv, :img_dir] => :environment do |t, args|
      import_tests_data(args.tests_questions_csv, args.img_dir)
    end
  end
end
