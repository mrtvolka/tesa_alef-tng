require 'test_helper'

class TeachingsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  def setup
    @student= User.where("role = 'student'").first
    @teacher=User.where("role = 'teacher'").first
    @admin=User.where("role = 'administrator'").first
  end

  test "student cannot get show" do
    @request.env["devise.mapping"] = Devise.mappings[:admin]
    sign_in @student

    get :show    # simulates a get request on happening_now action
    assert_redirected_to root_url
    sign_out @student
  end

  test "teacher can get show_test" do

    # devise
    sign_in @teacher

    #get show_my_test_url
    get :show    # simulates a get request on happening_now action
    assert_response :success    # makes sure response returns with status code 200


    # variables
    assert_not_nil assigns(:setup)
    assert_not_nil assigns(:exercises)

    #View
    assert_select 'h2', "#{assigns(:setup).name}- Stránka učiteľa"
    #TODO: add more stuff here

    sign_out @teacher
  end

  test "administrator can get show_test" do

    # devise
    sign_in @admin

    #get show_my_test_url
    get :show    # simulates a get request on happening_now action
    assert_response :success    # makes sure response returns with status code 200


    # variables
    assert_not_nil assigns(:setup)
    assert_not_nil assigns(:exercises)

    #View
    assert_select 'h2', "#{assigns(:setup).name}- Stránka učiteľa"
    assert_select "tr", assigns(:exercises).size+1
    #TODO: add more stuff here

    sign_out @admin
  end
end
