require 'test_helper'

  class ApplicationControllerTest < ActionController::TestCase
    include Devise::TestHelpers

    def setup
      @student= User.where("role = 'student'").first
      @teacher=User.where("role = 'teacher'").first
      @admin=User.where("role = 'administrator'").first
    end

    test "administator should not sign in with bad password" do
      assert(!@admin.valid_password?('badpasswd'), "admin: wrong password accepted")
    end

    test "teacher should not sign in with bad password" do
      assert(!@teacher.valid_password?('badpasswd'), "teacher: wrong password accepted")
    end

    test "student should not sign in with bad password" do
      assert(!@student.valid_password?('badpasswd'), "student: wrong password accepted")
    end

end