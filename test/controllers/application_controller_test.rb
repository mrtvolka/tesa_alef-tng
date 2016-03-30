require 'test_helper'


  class ApplicationControllerTest < ActionController::TestCase
    include Devise::TestHelpers

  def setup
    @student= User.where("role = 'student'").first
    @teacher=User.where("role = 'teacher'").first
    @admin=User.where("role = 'administrator'").first
  end

  test "student can sign in" do
    @request.env["devise.mapping"] = Devise.mappings[:admin]
    sign_in @student

    assert_response 200
    sign_out @student
  end

  test "administrator can sign in" do
    @request.env["devise.mapping"] = Devise.mappings[:admin]
    sign_in @admin

    assert_response 200
    sign_out @admin
  end


  test "Teacher can sign in" do
    @request.env["devise.mapping"] = Devise.mappings[:admin]
    sign_in @teacher

    assert_response 200
    sign_out @teacher
  end
end