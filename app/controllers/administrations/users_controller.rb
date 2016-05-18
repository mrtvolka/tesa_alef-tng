module Administrations
  class UsersController < ApplicationController
    authorize_resource :class => false

    # Specifies action for listing all users
    # get 'administrations/users'
    def index
      @users = User.all
    end

    # Specifies action for new user
    # get 'administrations/users/new'
    def new
      @user = User.new
    end

    # Specifies action for saving new created user
    # post 'administrations/users/:user_id/create'
    # checks if filled password are identical and if user login is not already used
    # checks some empty fields too
    # uses params posted in <tt>params[:user]</tt>
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
          redirect_to edit_administrations_user_path(@user), notice: t('.notice.created')
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
        render 'new'
      end
    end

    # Specifies action for editing existing user account
    # get 'administrations/users/:user_id/edit'
    # user for editing is selected using <tt>params[:user_id]</tt>
    def edit
      @user = User.find_by_id(params[:user_id])
    end

    # Specifies action for updating user account
    # patch 'administrations/users/:user_id/update'
    # updates user using params in <tt>params[:user_id]</tt>
    # checks if filled password are identical
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
