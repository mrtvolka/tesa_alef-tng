# Ruby script for generating exercises csv file for whole term using exercise schedule from csv file
# result can be imported to db using original simple csv rake
# using: run ruby exercisescsv2csv.rb [INPUT FILE] [TERM LENGTH]
# to import generated records to db run:
# rake tesa:data:import_exercises[exercises.csv]

require 'csv'
require 'active_support/all'

filename = ARGV.first
term_length = ARGV.second.to_i
exercise = {'start' => nil, 'end' => nil, 'lecturer' => nil}
code = 10001

# prepare new csv file and its header
CSV.open("exercises.csv", "wb") do |csv|
  csv << ["Exercise start", "Exercise end", "Code", "Lecturer", "Week"]
end
# go through each row in input csv file and create record for each week of term
CSV.foreach(filename, :headers => true) do |row|

  exercise.clear
  exercise['start'] = row[0]
  exercise['end'] = row[1]
  exercise['lecturer'] = row[2]

  exercise['start'] = Time.parse(exercise['start']).to_s
  exercise['end'] = Time.parse(exercise['end']).to_s

  for week in 1..term_length
    CSV.open("exercises.csv", "a+") do |csv|
      csv << [exercise['start'],exercise['end'],code,exercise['lecturer'],week]
    end
    code+=1
    exercise['start'] = (Time.parse(exercise['start']) + 7.days).to_s
  end
end
