require 'test_helper'

class QuestionsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  def setup
    @student= User.where("role = 'student'").first
    @teacher=User.where("role = 'teacher'").first
    @admin=User.where("role = 'administrator'").first
  end

  test "teacher cannot get show_test" do
    @request.env["devise.mapping"] = Devise.mappings[:admin]
    sign_in @teacher

    get(:show_test, {'week_id' => "1",'exercise_code' => "43864"})    # simulates a get request on happening_now action
    assert_redirected_to root_url
    sign_out @teacher
  end

  test "administrator cannot get show_test" do
    @request.env["devise.mapping"] = Devise.mappings[:admin]
    sign_in @admin

    get(:show_test, {'week_id' => "1",'exercise_code' => "43864"})    # simulates a get request on happening_now action
    assert_redirected_to root_url
    sign_out @admin
  end

  test "student can get show_test" do

    # devise
    sign_in @student

    #get show_my_test_url
    get(:show_test, {'week_id' => "1",'exercise_code' => "43864"})    # simulates a get request on happening_now action
    assert_response :success    # makes sure response returns with status code 200


    # variables
    assert_not_nil assigns(:setup)
    assert_not_nil assigns(:user)
    assert_not_nil assigns(:sorted_los)
    assert_not_nil assigns(:week)

    #View
    assert_select 'h2', 'Test'
    #TODO: change structure of html to better differentiate between question divs, look css_select
    assert_select "p" , assigns(@questions).size
    #TODO: add more stuff here

    sign_out @student
  end

  test "administrator cannot post submit_test" do
    @request.env["devise.mapping"] = Devise.mappings[:admin]
    sign_in @admin

    post(:submit_test, {'week_id' => "1",'exercise_code' => "43864"})    # simulates a get request on happening_now action
    assert_redirected_to root_url
    sign_out @admin
  end

  test "teacher cannot post submit_test" do
    @request.env["devise.mapping"] = Devise.mappings[:admin]
    sign_in @teacher

    post(:submit_test, {'week_id' => "1",'exercise_code' => "43864"})    # simulates a get request on happening_now action
    assert_redirected_to root_url
    sign_out @teacher
  end

  test "student can post submit_test" do
    @request.env["devise.mapping"] = Devise.mappings[:admin]
    sign_in @student
    get(:show_test, {'week_id' => "1",'exercise_code' => "43864"})
    assert_difference 'UserToLoRelation.count', assigns(@questions).size do
      post(:submit_test, {"questions"=>{"9"=>{"type"=>"EvaluatorQuestion", "commit"=>"send_answer"},
                                        "11"=>{"type"=>"EvaluatorQuestion", "commit"=>"send_answer"},
                                        "7"=>{"type"=>"MultiChoiceQuestion", "commit"=>"send_answer", "answer"=>{"18"=>"18"}},
                                        "6"=>{"type"=>"MultiChoiceQuestion", "commit"=>"send_answer", "answer"=>{"15"=>"15"}},
                                        "3"=>{"type"=>"SingleChoiceQuestion", "commit"=>"send_answer", "answer"=>"7"},
                                        "2"=>{"type"=>"SingleChoiceQuestion", "commit"=>"send_answer", "answer"=>"5"},
                                        "8"=>{"type"=>"MultiChoiceQuestion", "commit"=>"send_answer", "answer"=>{"21"=>"21"}},
                                        "5"=>{"type"=>"MultiChoiceQuestion", "commit"=>"send_answer", "answer"=>{"13"=>"13"}},
                                        "10"=>{"type"=>"EvaluatorQuestion", "commit"=>"send_answer"},
                                        "1"=>{"type"=>"SingleChoiceQuestion", "commit"=>"send_answer", "answer"=>"1"}},
                          "commit"=>"submit_test", "week_id"=>"1", "exercise_code"=>"43864"})    # simulates a get request on happening_now action
      assert_response :success
    end
    #TODO: add more here

    sign_out @student
  end
end