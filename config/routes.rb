Adt::Application.routes.draw do
  # codes
  resources :roles, :countries, :sectors, :statuses, 
  :verifieds, :oda_likes, :flow_types, :origins, # :tieds, 
  :source_types, :document_types, :organization_types, :currencies, :flag_types

  # limited access
  # get "/projects?scope=official_finance", to: "projects#index", as: 'projects'
  resources :projects, :organizations, :users
  resources :comments, only: [:create, :destroy, :show]
  resources :flags, only: [:create, :destroy, :show]
  
  # special purpose
  resources :sessions, only: [:new, :create, :destroy]
  resources :relationships
  match '/aggregates/export', to: 'static_pages#aggregator'
  match '/aggregates/projects', to: 'aggregates#projects', :defaults=>{:format=>'json'}
  match '/projects/json', to: 'projects#index', defaults: { format: 'json'}
  post '/users/:id/own/:owner_id', to: 'users#own'
  post '/users/:id/disown', to: 'users#disown'

  # Versions -- revert action, and index for all recent activity
  post '/versions/:id/revert', to: 'versions#revert', as: 'revert_version'
  get '/recent_activity', to: 'versions#index', as: 'versions'
  
  # static pages
  root to: "static_pages#home"
  match '/china', to: "static_pages#home"
	get '/analyze', to: "static_pages#analyze"

  match '/signup', to: 'users#new'
  match '/signin', to: 'sessions#new'
  match '/signout', to: 'sessions#destroy', via: :delete

  match '/ajax', to: 'static_pages#ajax'

end
