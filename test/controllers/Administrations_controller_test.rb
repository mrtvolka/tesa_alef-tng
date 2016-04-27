require 'test_helper'

class AdministrationsControllerTest < ActionController::TestCase
  include Devise::TestHelpers


  def setup
    @student= User.where("login = 'student1'").first
    @teacher=User.where("role = 'teacher'").first
    @admin=User.where("role = 'administrator'").first
    #@exercise=Exercise.where("real_start IS NOT NULL").first
    #@ended_exercise=Exercise.where("real_end IS NOT NULL").first
  end

  test "student cannot get setup_config" do
    @request.env["devise.mapping"] = Devise.mappings[:admin]
    sign_in @student
    get :setup_config, 'setup_id' => 1
    assert_redirected_to root_url
    sign_out @student
  end

  test "teacher cannot get setup_config" do
    @request.env["devise.mapping"] = Devise.mappings[:admin]
    sign_in @teacher
    get :setup_config, 'setup_id' => 1
    assert_redirected_to root_url
    sign_out @student
  end

  test "admin can get setup_config" do
    @request.env["devise.mapping"] = Devise.mappings[:admin]
    sign_in @admin
    get :setup_config, 'setup_id' => 1
    assert_response :success
    sign_out @admin
  end


end