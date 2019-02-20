class SessionsController < ApplicationController

    # Page de connexion
    def login
    end

    # Vérification de la connexion
    def check
        user = User.find_by_email(params[:email])

        if user && user.authenticate(params[:password])
            session[:user_id] = user.id
            redirect_to '/'
        else
            flash[:info] = "Connexion failed."
            redirect_to '/users/login'
        end
    end

    # Déconnexion
    def logout
        session.delete(:user_id)

        redirect_to  '/users/login'
    end
end