Rails.application.routes.draw do

  mathjax 'mathjax'

  get 'exercises/show'

  get 'exercises/edit'

  resources :exercises do

  end

  root to: redirect('i')

  devise_for :ldap_users, :local_users, skip: [:sessions]
  # the login controllers and views are shared for local and ldap users, use :local_user for routes
  devise_scope :local_user do
    get 'login',     to: 'users/sessions#new',     as: 'new_user_session'
    post 'login',    to: 'users/sessions#create',  as: 'user_session'
    delete 'logout', to: 'users/sessions#destroy', as: 'destroy_user_session'
  end

  # Vypis tyzdnov z daneho setupu, napr. /PSI
  get 'w' => 'weeks#list', as: 'weeks'

    # Vypis otazok z daneho tyzdna, napr. /PSI/3
  get 'w/:week_number' => 'weeks#show'

  # Vrati dalsiu otazku podla odporucaca
  get 'w/:week_number/next' => 'questions#next'

  # Vypis otazky, napr. /PSI/3/16-validacia-a-verifikacia
  get 'w/:week_number/:id' => 'questions#show', as: 'questions'
  get 'w/:week_number/:id/image' => 'questions#show_image', as: 'qimages'

  # Loguje cas straveny na otazke
  post 'log_time' => 'questions#log_time'

  # Opravi otazku a vrati spravnu odpoved
  post 'w/:week_number/:id/evaluate_answers' => 'questions#evaluate'

  # Prepina zobrazovenie odpovedi ku otazkam
  post 'user/toggle-show-solutions' => 'users#toggle_show_solutions'

  post 'feedback' => 'users#send_feedback', as: 'feedback'



  # Administracia
  get 'admin' => 'administrations#index', as: 'administration'

  get 'admin/setup_config/:setup_id' => 'administrations#setup_config', as: 'setup_config'
  get 'admin/setup_config/:setup_id/download_statistics' => 'administrations#download_statistics', as: 'download_statistics'
  post 'admin/setup_config/:setup_id/setup_attributes' => 'administrations#setup_config_attributes', as: 'setup_attributes'
  post 'admin/setup_config/:setup_id/setup_relations' => 'administrations#setup_config_relations', as: 'setup_relations'

  get 'admin/question_concept_config/:course_id' => 'administrations#question_concept_config', as: 'question_concept_config'
  post 'admin/question_concept_config/:course_id/delete_question_concept' => 'administrations#delete_question_concept', as: 'delete_question_concept'
  post 'admin/question_concept_config/:course_id/add_question_concept' => 'administrations#add_question_concept', as: 'add_question_concept'

  #Ucenie
  get 'teaching' => 'teachings#show', as: 'teaching'

  #testovanie

  get 'test/:exercise_code' => 'questions#show_test'
  post 'test/:exercise_code/submit' => 'questions#submit_test', as: 'submit_test'

  get 'test/:exercise_id/answers' => 'questions#show_answers'
  get 'test/:week_number/access' => 'questions#access_answers'


  get 'enter_test' => 'weeks#enter_test', as: 'enter_test'
  post 'check_code' => 'questions#check_code'

  get 'exercises/event/refresh' => 'exercises#refresh'
  get 'exercise/statistics' => 'teachings#statistics' , as: 'statistics'
  get 'tests' => 'weeks#test_list', as: 'tests'

  get 'i' => 'weeks#index'

end
