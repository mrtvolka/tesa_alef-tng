require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'pandoc-ruby'
require 'csv'
require 'rake'

namespace :tesa do

   task :allinone => :environment do


    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke

    ActiveRecord::Base.transaction do
      Rake::Task['db:migrate'].invoke
    end

    ActiveRecord::Base.transaction do
        #%x(rake db:seed)
        #%x(rake tesa:data:import_users[usersdump1.csv])
        #%x(rake tesa:data:import_exercises[exercises.csv])
        #%x(rake tesa:data:import_OStests[tema05.csv])

        # Ready for AZA:

        #Rake::Task['tesa:data:aza_setup'].invoke
        puts %x(rake tesa:data:aza_setup)
        puts %x(rake tesa:data:import_users[azausers.csv])
        puts %x(rake tesa:data:import_exercises[exercises.csv])
        puts %x(rake tesa:data:import_tests[otazkyAZA.csv,img])
        #Kernel.system('rake tesa:data:import_users[azausers.csv]')
        #Rake::Task['tesa:data:import_exercises'].invoke('exercises.csv')
        #Kernel.system('rake tesa:data:import_tests[otazkyAZA.csv,img]')
    end
  end
end