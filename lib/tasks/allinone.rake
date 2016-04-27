require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'pandoc-ruby'
require 'csv'
require 'rake'

namespace :tesa do

  def try_drop(forced)
    Open3::popen3('rake db:drop') do |stdin, stdout, stderr|
      unless stdout.gets.nil?
        puts stdout.read
      end
      error= stderr.read
      if error.include?("Couldn't drop aleftng_development")
      #unless stderr.gets.nil?
        STDERR.puts error
        STDERR.puts "Error: Couldn't drop database, are you still connected?"
        unless forced
          exit 0
        end
      end
    end
  end

  def try_create(forced)
    Open3::popen3('rake db:create') do |stdin, stdout, stderr|
      unless stdout.gets.nil?
        puts stdout.read
      end
      unless stderr.gets.nil?
        STDERR.puts stderr.read
        STDERR.puts "Error: Couldn't create database"
        unless forced
          exit 0
        end
      end
    end
  end

  def try_migrate(forced)
    Open3::popen3('rake db:migrate') do |stdin, stdout, stderr|
      unless stdout.gets.nil?
        puts stdout.read
      end
      unless stderr.gets.nil?
        STDERR.puts stderr.read
        STDERR.puts "Error: Couldn't migrate database"
        unless forced
          exit 0
        end
      end
    end
  end

  def universal_import(forced, verbose)
    try_drop forced
    try_create forced
    try_migrate forced

    #Seed
    if forced
      puts %x(rake tesa:data:aza_setup)
      puts %x(rake tesa:data:import_users[azausers.csv])
      puts %x(rake tesa:data:import_tests[otazkyAZA.csv,img])
      puts %x(rake tesa:data:import_exercises[exercises.csv])
    else
      ActiveRecord::Base.transaction do

        #%x(rake db:seed)
        #%x(rake tesa:data:import_users[usersdump1.csv])
        #%x(rake tesa:data:import_exercises[exercises.csv])
        #%x(rake tesa:data:import_OStests[tema05.csv])

        # Ready for AZA:

        #Rake::Task['tesa:data:aza_setup'].invoke
        puts %x(rake tesa:data:aza_setup)
        puts %x(rake tesa:data:import_users[azausers.csv])
        puts %x(rake tesa:data:import_tests[otazkyAZA.csv,img])
        puts %x(rake tesa:data:import_exercises[exercises.csv])
        #Kernel.system('rake tesa:data:import_users[azausers.csv]')
        #Rake::Task['tesa:data:import_exercises'].invoke('exercises.csv')
        #Kernel.system('rake tesa:data:import_tests[otazkyAZA.csv,img]')
      end
    end
  end


  task :allinone => :environment do
    # Arguments
    if ENV['FORCED'].to_s.eql?("true")
      puts "INFO: importer works in FORCED mode, if it cannot drop db, it will be appended or rewritten"
      forced= true
    elsif ENV['FORCED'].to_s.eql?("false") || ENV['FORCED'].nil?
      forced= false
    else
      puts "WARNING: unrecognized argument value '#{ENV['VERBOSE']}', falling back to default values"
      forced= false
    end

    if ENV['VERBOSE'].to_s.eql?("ALL") || ENV['VERBOSE'].nil?
      verbose= 3
    elsif ENV['VERBOSE'].to_s.eql?("INFO")
      verbose= 2
    elsif ENV['VERBOSE'].to_s.eql?("ERROR")
      verbose= 1
    elsif ENV['VERBOSE'].to_s.eql?("NONE")
      verbose= 0
    else
      puts "WARNING: unrecognized argument value '#{ENV['VERBOSE']}', falling back to default values"
      verbose= 3
    end

    if verbose== 0
      quietly do
        universal_import(forced,verbose)
      end
    elsif verbose== 1
      silence_stream(STDOUT) do
        universal_import(forced,verbose)
      end
    elsif verbose== 2
      silence_stream(STDERR) do
        universal_import(forced,verbose)
      end
    else
      universal_import(forced,verbose)
    end
  end
end