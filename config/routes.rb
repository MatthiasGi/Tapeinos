Rails.application.routes.draw do

  # Setup wizard
  resources :setup

  # Session-management
  get '/login/as/:id' => 'sessions#update', as: 'change_server'
  get '/login/:seed' => 'sessions#temporary', \
    constraints: { seed: /[a-f0-9]{32}/ }, as: 'login_seed'
  get '/login' => 'sessions#new'
  post '/login' => 'sessions#create'
  get '/logout' => 'sessions#destroy'
  get '/login/:email' => 'sessions#new', \
    constraints: { email: /[\S]+@[\S]+\.[\S]+/ }

  # Displays the plan-overview as root.
  root 'plans#index'

  # Management of forgot passwords.
  get '/forgot-password' => 'forgot_passwords#new'
  post '/forgot-password' => 'forgot_passwords#create'
  get '/forgot-password/:token' => 'forgot_passwords#edit', \
    constraints: { token: /[a-f0-9]{32}/ }
  post '/forgot-password/save' => 'forgot_passwords#update'

  # Non-administrative user-managment
  get '/register' => 'users#new'
  get '/register/do' => 'users#create'
  get '/settings.bak' => 'users#edit'
  post '/settings.bak' => 'users#update'
  delete '/settings.bak' => 'users#destroy'
  # TODO: Old routes for editing / destroying users are deprecated

  # Interface for user-settings
  get 'settings' => 'settings#servers'
  get 'settings/servers'
  post 'settings/servers' => 'settings#servers_update'
  get 'settings/data'
  post 'settings/data' => 'settings#data_update'
  get 'settings/security'
  get 'settings/security/generate' => 'settings#security_do'
  get 'settings/delete'
  delete 'settings/delete' => 'settings#delete_do'

  # Non-administrative plan-interface.
  resources :plans, only: [ :index, :show, :update ]

  # Administrative REST-API
  namespace :admin do
    resources :servers, except: :show
    resources :users, only: [ :index, :edit, :update, :destroy ]
    resources :plans

    resources :messages
    get '/messages/:id/mail' => 'messages#mail', as: 'message_mail'

    resources :settings, only: :index
    post '/settings' => 'settings#update'
  end

  # Static pages
  get '/about' => 'pages#about'

end
