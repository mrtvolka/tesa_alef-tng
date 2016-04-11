require 'test_helper'

class WeeksControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  def setup
    @student= User.where("role = 'student'").first
    @teacher=User.where("role = 'teacher'").first
    @admin=User.where("role = 'administrator'").first
    @exercise=Exercise.first
  end

  test "student should get list" do
    @request.env["devise.mapping"] = Devise.mappings[:admin]
    sign_in @student
    get :list
    assert_response :success
    sign_out @student
  end

  test "teacher should get list" do
    @request.env["devise.mapping"] = Devise.mappings[:admin]
    sign_in @teacher
    get :list
    assert_response :success
    sign_out @teacher
  end

  test "admin should get list" do
    @request.env["devise.mapping"] = Devise.mappings[:admin]
    sign_in @admin
    get :list
    assert_response :success
    sign_out @admin
  end

  test "student should get test list" do
    @request.env["devise.mapping"] = Devise.mappings[:admin]
    sign_in @student
    get :test_list
    assert_response :success
    sign_out @student
  end

  test "teacher should get test list" do
    @request.env["devise.mapping"] = Devise.mappings[:admin]
    sign_in @teacher
    get :test_list
    assert_response :success
    sign_out @teacher
  end

  test "admin should get test list" do
    @request.env["devise.mapping"] = Devise.mappings[:admin]
    sign_in @teacher
    get :test_list
    assert_response :success
    sign_out @teacher
  end

  test "student should get index" do
    @request.env["devise.mapping"] = Devise.mappings[:admin]
    sign_in @student
    get :index
    assert_response :success
    sign_out @student
  end

  test "teacher should get index" do
    @request.env["devise.mapping"] = Devise.mappings[:admin]
    sign_in @teacher
    get :index
    assert_response :success
    sign_out @teacher
  end

  test "admin should get index" do
    @request.env["devise.mapping"] = Devise.mappings[:admin]
    sign_in @admin
    get :index
    assert_response :success
    sign_out @admin
  end

#=begin
  test "student should get show" do
    @request.env["devise.mapping"] = Devise.mappings[:admin]
    sign_in @student
    #@setup=Setup.first
    get :show, 'week_number' => 1
    assert_response :success
    sign_out @student
  end
#=end

end
