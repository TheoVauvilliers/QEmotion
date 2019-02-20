class ApplicationController < ActionController::Base
    helper_method :current_user, :logged_in?

    private

    # Récupère les infos de l'utilisateur
    def current_user
        @current_user ||= User.find_by_id(session[:user_id])
    end

    # Permets de savoir si l'utilisateur est connecté
    def logged_in?
        current_user != nil
    end

end