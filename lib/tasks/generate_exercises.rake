require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'pandoc-ruby'
require 'csv'

namespace :tesa do
  namespace :data do

    def generate_exercises(file, semester_length)
      # simple exercise code version for development
      code = 10001
      # read whole csv
      CSV.read(file, :headers =>  true).each do |row|
        Exercise.create!(:start => row['Exercise start'], :end => row['Exercise end'], :user_id => row['Lecturer'],
                         :week_id => Week.find_by_number(1).id, :code => code)
        # change code for each exercise
        code += 1
      end
      # process all existing exercise records from csv

      Exercise.all.each do |exercise|
        # for each record create duplicated records with different timestamps
        $i = 2
        while $i < 12 do
          # iterate with one week
          exercise.start += 7.days
          exercise.end += 7.days
          exercise.code = code
          # check presence of week (for week id purpose)
          if(!Week.find_by_number($i).nil?)
            exercise.week_id = Week.find_by_number($i).id
            # if week with i number exists, create new record for this exercise
            Exercise.create!(:start => exercise.start, :end => exercise.end, :user_id => exercise.user_id,
                             :code => exercise.code, :week_id => exercise.week_id)
          end
          code +=1
          $i += 1
        end
      end
    end

    # generate exerices using CSV schedule file
    # run:
    #    rake tesa:data:import_schedule[filename.csv, semester_length]
    #    use csv file with exercises schedule prepared for 1st week of semester
    task :import_schedule, [:schedule_csv, :semester_length] => :environment do |t, args|
      generate_exercises(args.schedule_csv, args.semester_length)
    end
  end
end
