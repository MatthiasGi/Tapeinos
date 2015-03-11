Rails.application.routes.draw do

  # Session-management
  get '/login/as/:id' => 'sessions#update', as: 'change_server'
  get '/login/:seed' => 'sessions#temporary', \
    constraints: { seed: /[a-f0-9]{32}/ }, as: 'login_seed'
  get '/login' => 'sessions#new'
  post '/login' => 'sessions#create'
  get '/logout' => 'sessions#destroy'

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
  get '/settings' => 'users#edit'
  post '/settings' => 'users#update'
  delete '/settings' => 'users#destroy'

  # Plans-placeholder
  resources :plans, only: [ :index, :show ]

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
