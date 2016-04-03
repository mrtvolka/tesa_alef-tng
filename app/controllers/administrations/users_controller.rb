module Administrations
  class UsersController < ApplicationController
    authorize_resource :class => false

    # all teachings
    def index
      @users = User.all
    end

    # add new teaching
    def new
      @user = User.new
    end

    def create
      begin
        @user = User.new(user_params)
        if(params[:user][:password].empty? || params[:user][:password] != params[:user][:confirm_password])
          raise PasswordsNotMatchError
        else
          if params[:user][:login].empty?
            raise LoginEmptyError
          end
          user = User.find_by_login(params[:user][:login])
          if !user.nil?
            raise LoginExistsError
          end
          @user = User.create!(user_params_with_password)
          redirect_to edit_administrations_user_path(@user), notice: t('admin.user.texts.created')
        end
      rescue PasswordsNotMatchError
        flash[:notice] = t('global.password.notmatch_or_empty')
        render 'new'
      rescue LoginExistsError
        flash[:notice] = t('global.login.exists')
        render 'new'
      rescue LoginEmptyError
        flash[:notice] = t('global.login.empty')
        render 'new'
      rescue ActiveRecord::RecordInvalid
        flash[:notice] = t('global.texts.please_fill_in')
        flash[:notice] = t('global.texts.please_fill_in')
        render 'new'
      end
    end

    def edit
      @user = User.find_by_id(params[:user_id])
    end

    def update
      begin
        @user = User.find(params[:user_id])
        if(!params[:user][:password].nil? && params[:user][:password] == params[:user][:confirm_password])
          @user.update!(user_params_with_password)
        else
          @user.update!(user_params)
          if(params[:user][:password] != params[:user][:confirm_password])
            raise PasswordsNotMatchError
          end
        end
        redirect_to edit_administrations_user_path(@user), notice: t('global.texts.updated')
      rescue PasswordsNotMatchError
        flash[:notice] = t('global.password.notmatch')
        render 'edit'
      rescue ActiveRecord::RecordInvalid
        flash[:notice] = t('global.texts.please_fill_in')
        render 'edit'
      end
    end

    def destroy

    end

    private

    def user_params
      params.require(:user).permit(:login, :role, :first_name, :last_name, :email)
    end

    def user_params_with_password
      params.require(:user).permit(:login, :role, :first_name, :last_name, :email, :type, :password)
    end


  end
end
