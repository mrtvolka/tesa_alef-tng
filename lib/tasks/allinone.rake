require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'pandoc-ruby'
require 'csv'
require 'rake'

namespace :tesa do

  task :allinone do
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    Rake::Task['db:migrate'].invoke
    #%x(rake db:seed)
    #%x(rake tesa:data:import_users[usersdump1.csv])
    #%x(rake tesa:data:import_exercises[exercises.csv])
    #%x(rake tesa:data:import_OStests[tema05.csv])

    # Ready for AZA:
    %x(rake tesa:data:aza_setup)
    %x(rake tesa:data:import_users[azausers.csv])
    %x(rake tesa:data:import_exercises[exercises.csv])
    %x(rake tesa:data:import_tests[otazkyAZA.csv,img])
  end
end