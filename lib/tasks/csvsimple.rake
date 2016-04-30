require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'pandoc-ruby'
require 'csv'

# simple csv importer for tesa alef data
namespace :tesa do
  namespace :data do

    # import exercises from csv
    def import_exercises(file)
      CSV.read(file, :headers => true).each do |row|
         # row names in [] must be same in csv file!
          exercise=Exercise.new(:start => row['Exercise start'], :end => row['Exercise end'],
                                  :code => row['Code'], :user_id => row['Lecturer'], :week_id => row['Week'],:cooldown_time_amount => 5)

          concepts= row['Concepts'].split(';')
          concepts.each do |concept_name|
            concept = Concept.find_or_create_by(name: concept_name) do |c|
              c.course = Course.first
              c.pseudo = (concept_name == Concept::DUMMY_CONCEPT_NAME)
            end
            exercise.concepts << concept
          end
          exercise.save
      end
    end

    # import users from csv
    def import_users(file)
      CSV.read(file, :headers => true).each do |row|

        # role types format parsing to db role types
        roleName = row['Role']
        if roleName == 'student'
          assign_role = User::ROLES[:STUDENT];
        elsif roleName == 'teacher'
          assign_role = User::ROLES[:TEACHER];
        elsif roleName == 'administrator'
          assign_role = User::ROLES[:ADMINISTRATOR];
        else
          assign_role = 0
        end
        # row names in [] must be same in csv file!
        User.create!(:login => row['Login'], :role => assign_role , :first_name => row['First name'],
                      :last_name => row['Last name'], :password => row['Password'], :type => row['Type'])

      end
    end

    # import concepts from csv
    def import_weekly_concepts(file)
      ActiveRecord::Base.transaction do
        CSV.read(file, :headers => true).each do |row|
          concepts= row['Concept'].split(';')
          concepts.each do |concept_name|
            concept=Concept.where('name = (?)',concept_name).first_or_create do |newConcept|
              puts "INFO: New Concept on-the-fly generation"
              newConcept.name= concept_name
              newConcept.pseudo= false
              newConcept.course_id= Course.take.id
              puts "INFO: New Concept created with name :#{concept_name}"
            end
            if row['week_id_or_number']== 'id'
              w= Week.where('id= (?)',row['Week']).first_or_create do |newWeek|
                puts "INFO: New week on-the-fly generation, please write week_number"
                newWeek.number= STDIN.gets.to_i
                newWeek.setup_id= Setup.take.id
              end
              if (!concept.weeks.include?(w))
                concept.weeks << w
              else
                puts "WARNING: Tried to assign concept to week duplicitly"
              end
            else
              w= Week.where('number= (?)',row['Week']).first_or_create do |newWeek|
                puts "INFO: New week on-the-fly generation"
                newWeek.number= row['Week']
                newWeek.setup_id= Setup.take.id
              end
              if (!concept.weeks.include?(w))
                concept.weeks << w
              else
                puts "WARNING: Tried to assign concept to week duplicitly"
              end
            end
            puts "INFO: Added Concept with name #{concept_name} to week with id #{w.id}"
          end
        end
      end
    end

    # import exercises from CSV files
    # run:
    #    rake tesa:data:import_exercises[filename.csv]
    task :import_exercises, [:exercise_csv] => :environment do |t, args|
      import_exercises(args.exercise_csv)
    end

    # import weekly-concepts
    # run:
    #     rake tesa:data:import_weekly_concepts[filename.csv]
    task :import_weekly_concepts, [:concepts_csv] => :environment do |t, args|
      import_weekly_concepts(args.concepts_csv)
    end

    # import users from CSV files
    # run:
    #    rake tesa:data:import_users[filename.csv]
    task :import_users, [:users_csv] => :environment do |t, args|
      import_users(args.users_csv)
    end
  end
end
