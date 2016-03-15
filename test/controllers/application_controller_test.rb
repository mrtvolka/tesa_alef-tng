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
    get "/login"

    assert_redirected_to new_user_session_path
    sign_out @student
  end

  test "administrator can sign in" do
    @request.env["devise.mapping"] = Devise.mappings[:admin]
    sign_in @admin
    get "/login"

    assert_redirected_to new_user_session_path
    sign_out @admin
  end


  test "Teacher can sign in" do
    @request.env["devise.mapping"] = Devise.mappings[:admin]
    sign_in @teacher
    get "/login"

    assert_redirected_to new_user_session_path
    sign_out @teacher
  end

  #test "Unknown user cannot sign in" do
  #  @request.env["devise.mapping"] = Devise.mappings[:admin]
  #  sign_in @teacher # TODO unknown user

  #  assert_redirected_to new_user_session_path
  #  sign_out @teacher
  #end

  class UserFlowsTest < ActionDispatch::IntegrationTest
    test "login through http" do
    # login via http
    http!
    get "/login"
    assert_response :success

    post_via_redirect "/login", username: users(:student1).username, password: users(:student1).password # add valid username and password
    assert_equal 'Úspešne prihlásený.', flash[:notice]

    DELETE "/logout"
    assert_equal 'Úspešne odhlásený.', flash[:notice]
    end

    test "login through https" do
    # login via https
    https! # use only with valid certificate
    get "/login"
    assert_response :success

    post_via_redirect "/login", username: users(:student1).username, password: users(:student1).password # add valid username and password
    assert_equal 'Úspešne prihlásený.', flash[:notice]

    DELETE "/logout"
    assert_equal 'Úspešne odhlásený.', flash[:notice]
    end

    test "unauthorized user cannot login"
    get "/login"
    assert_response :success

    post_via_redirect "/login", username: users(:xdekanm1).username, password: users(:wrongpassword).password # wrong password test
    assert_equal 'Nesprávne prihlasovacie meno alebo heslo.'
    post_via_redirect "/login", username: users(:useruser).username, password: users(:wrongpassword).password # not existing user
    assert_equal 'Nesprávne prihlasovacie meno alebo heslo.'
    end
end