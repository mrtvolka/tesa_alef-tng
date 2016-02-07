course = Course.where(name: 'Course One').first
if course
  course.update(name: 'OS')
else
  course = Course.create!(name: 'OS')
end

setup = Setup.create!(name: 'OS 2016', first_week_at: '2016-02-01 00:00:00.00000', week_count: 12, course_id: course.id)

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

users = User.create!([
                         {login: 'student1', role: User::ROLES[:STUDENT], first_name: 'Peter', last_name: 'Studentovic', password: 'student1', type: 'LocalUser'},
                         {login: 'student2', role: User::ROLES[:STUDENT], first_name: 'Roman', last_name: 'Studentovic', password: 'student2', type: 'LocalUser'},
                         {login: 'teacher1', role: User::ROLES[:TEACHER], first_name: 'Fero', last_name: 'Ucitelovic', password: 'teacher1', type: 'LocalUser'},
                         {login: 'administrator1', role: User::ROLES[:ADMINISTRATOR], first_name: 'Lubos', last_name: 'Adminovic', password: 'administrator1', type: 'LocalUser'},
                     ])

