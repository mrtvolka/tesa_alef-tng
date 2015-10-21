users = User.create!([
                         {login: 'teacher10', role: User::ROLES[:TEACHER], first_name: 'Fero', last_name: 'Ucitelovic', password: 'teacher1', type: 'LocalUser'},
                         {login: 'teacher11', role: User::ROLES[:TEACHER], first_name: 'Jano', last_name: 'Ucitelovic', password: 'teacher1', type: 'LocalUser'},
                         {login: 'teacher12', role: User::ROLES[:TEACHER], first_name: 'Juro', last_name: 'Ucitelovic', password: 'teacher1', type: 'LocalUser'},
                         {login: 'teacher13', role: User::ROLES[:TEACHER], first_name: 'Peter', last_name: 'Ucitelovic', password: 'teacher1', type: 'LocalUser'},
                         {login: 'teacher14', role: User::ROLES[:TEACHER], first_name: 'Michal', last_name: 'Ucitelovic', password: 'teacher1', type: 'LocalUser'},
                     ])

weeks = Week.all

exercises = Exercise.create!(
                        [
                            {code: 13568, user_id: users[0].id, week_id: 1, test_started: false},
                            {code: 17894, user_id: users[1].id, week_id: 2, test_started: false},
                            {code: 25864, user_id: users[1].id, week_id: 3, test_started: false},
                            {code: 85246, user_id: users[2].id, week_id: 1, test_started: false},
                            {code: 45823, user_id: users[2].id, week_id: 2, test_started: false},
                            {code: 45244, user_id: users[3].id, week_id: 3, test_started: false},
                            {code: 10535, user_id: users[3].id, week_id: 4, test_started: false},
                            {code: 37561, user_id: users[3].id, week_id: 3, test_started: false},
                            {code: 12543, user_id: users[4].id, week_id: 1, test_started: false},
                            {code: 50050, user_id: users[4].id, week_id: 2, test_started: false}
                        ]
)

