# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


load(Rails.root.join( 'db', '', "#{Rails.env.downcase}.rb"))

# only for development usage, csv files will be used later
#load(Rails.root.join( 'db', '', "#{Rails.env.downcase}_tesa.rb"))

