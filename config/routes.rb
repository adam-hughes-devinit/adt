Adt::Application.routes.draw do
  # codes
  resources :roles, :countries, :sectors, :statuses, 
  :verifieds, :oda_likes, :tieds, :flow_types, :origins, 
  :source_types, :document_types, :organization_types, :currencies, :flag_types

  # limited access
  resources :projects, :organizations, :users
  resources :comments, only: [:create, :destroy, :show]
  # special purpose
  resources :sessions, only: [:new, :create, :destroy]
  resources :relationships
  match '/aggregates/projects', to: 'aggregates#projects'
  post '/users/:id/own/:owner_id', to: 'users#own'
  post '/users/:id/disown', to: 'users#disown'

  # Versions -- revert action, and index for all recent activity
  post '/versions/:id/revert', to: 'versions#revert', as: 'revert_version'
  get '/recent_activity', to: 'versions#index', as: 'versions'
  
  root to: "static_pages#home"
  match '/china', to: "static_pages#home"

  match '/signup', to: 'users#new'
  match '/signin', to: 'sessions#new'
  match '/signout', to: 'sessions#destroy', via: :delete

  match '/ajax', to: 'static_pages#ajax'
  
  get "static_pages/vis"

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
