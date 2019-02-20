class UsersController < ApplicationController

    # Page de création d'utilisateur
    def new
    end

    # Vérification de la création
    def create

        user = User.new(user_params)

        if User.where(:email => user.email).blank?
            if user.save
                session[:user_id] = user.id

                redirect_to '/users/login'
            else
                redirect_to '/users/signup'
            end
        else
            flash[:info] = "Already used email."

            redirect_to '/users/signup'
        end
    end

    private

    def user_params
        params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

end