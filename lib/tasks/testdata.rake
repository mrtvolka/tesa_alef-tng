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

    def import_concepts(local_concepts_string,global_concepts_string,learning_object,week_number)
      if (local_concepts_string.nil? || local_concepts_string.empty? )&&(global_concepts_string.nil? || global_concepts_string.empty?)
        puts "WARNING: '#{learning_object.external_reference}' - '#{learning_object.lo_id}' has no concepts"
        local_concepts_string = Concept::DUMMY_CONCEPT_NAME
      end

      week = Week.find_or_create_by(number: week_number) do |w|
        w.setup = Setup.first
      end

      local_concept_names = local_concepts_string.split(';').map{|x| week_number + ". týždeň - " + x.strip}
      local_concept_names.each do |concept_name|
        #concept_name =  + concept_name
        concept = Concept.where("name = (?) ",concept_name).first_or_create do |c|
          c.name= concept_name
          c.course = Course.first
          c.pseudo = (concept_name == Concept::DUMMY_CONCEPT_NAME)
        end
        concept.weeks << week unless concept.weeks.include? week
        learning_object.link_concept(concept)
      end

      global_concept_names = global_concepts_string.split(';')
      global_concept_names.each do |concept_name|
        #concept_name =  + concept_name
        concept = Concept.where("name = (?) ",concept_name).first_or_create do |c|
          c.name= concept_name
          c.course = Course.first
          c.pseudo = (concept_name == Concept::DUMMY_CONCEPT_NAME)
        end
        learning_object.link_concept(concept)
      end
      learning_object.concepts.delete(learning_object.concepts.where("name NOT IN (?) AND name NOT IN (?)",global_concept_names,local_concept_names))
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
        local_concept_names = row[2]
        global_concept_names = row[3]
        question_type = TESA_QUESTION_TYPES[row[4]]
        answers = row[5]
        difficulty_text = row[6]
        picture = row[7]
        is_special = check_is_special_flag(row[8])
        week_number = row[9]

        lo = LearningObject.find_or_create_by(question_text: question_text) do |lo|
          lo.course = Course.first
        end

        lo.update( type: question_type, lo_id: question_name, question_text: question_text, is_test_question: true, is_special_question: is_special)

        if (!TESA_QUESTION_TYPES.has_key?(row[4]))
          puts "WARNING: '#{lo.external_reference}' - '#{lo.lo_id}' has unknown question type!"
        end

        if question_name.nil?
          puts "WARNING: '#{lo.external_reference}' - '#{lo.lo_id}' has question name undefined!"
        end

        if  question_text.nil?
          puts "WARNING: '#{lo.external_reference}' - '#{lo.lo_id}' has questtion text undefined!"
        end

        # TODO import answers when updating existing LO, not only upon first creation
        # ^NOTE: answer ID should be preserved whenever possible for logged relations
        if lo.answers.empty? && question_type != 'OpenQuestion'
          if(question_type == 'SingleChoiceQuestion' && answers.scan(/<correct>/).length>1) || (question_type != 'EvaluatorQuestion' && answers.scan(/<correct>/).length==0)
            puts "WARNING: '#{lo.external_reference}' - '#{lo.lo_id}' has wrong number of correct answers"
          end
          answers.split(';').each do |answer|
            correct_answer = answer.include? '<correct>'
            answer_text = convert_format(answer, true)
            Answer.create!( learning_object_id: lo.id, answer_text: answer_text, is_correct: correct_answer )
          end
        end

        import_difficulty(difficulty_text, lo)
        import_concepts(local_concept_names,global_concept_names, lo, week_number)
        import_pictures(picture, pictures_dir, lo) if picture
        puts "INFO: '#{lo.external_reference}' - '#{lo.lo_id}' was saved"
      end
    end

    task :import_tests, [:tests_questions_csv, :img_dir] => :environment do |t, args|
      import_tests_data(args.tests_questions_csv, args.img_dir)
    end
  end
end
