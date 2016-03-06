namespace :tesa do
  namespace :data do

    def setup_AZA
      course = Course.where(name: 'Course One').first
      if course
        course.update(name: 'AZA')
      else
        course = Course.create!(name: 'AZA')
      end

      setup = Setup.create!(name: 'AZA 2016', first_week_at: '2016-03-07 00:00:00.00000', week_count: 12, course_id: course.id)

      weeks = Week.create!([
                               {setup_id: setup.id, number: 1},
                               {setup_id: setup.id, number: 2},
                               {setup_id: setup.id, number: 3},
                               {setup_id: setup.id, number: 4},
                               {setup_id: setup.id, number: 5},
                               {setup_id: setup.id, number: 6},
                               {setup_id: setup.id, number: 7},
                               {setup_id: setup.id, number: 8},
                               {setup_id: setup.id, number: 9},
                               {setup_id: setup.id, number: 10},
                               {setup_id: setup.id, number: 11},
                               {setup_id: setup.id, number: 12},
                           ])
    end

    task :aza_setup => :environment do
      setup_AZA
    end
  end
end
