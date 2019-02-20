Rails.application.routes.draw do

    # Page d'accueil
    get '/' => 'home#home'

    # Pages d'inscription
    get 'users/signup' => 'users#new'
    post 'users/signup' => 'users#create'

    # Pages d'authentification
    get 'users/login' => 'sessions#login'
    post 'users/login' => 'sessions#check'

    # Déconnexion
    get 'logout' => 'sessions#logout'

    # Pages de recherche
    get 'search' => 'search#form'
    post 'search' => 'search#result'
end