Adt::Application.routes.draw do
  # codes
  resources :roles, :countries, :crs_sectors, :statuses, 
  :verifieds, :oda_likes, :flow_types, :origins, :intents, # :tieds, 
  :source_types, :document_types, :organization_types, :currencies, 
  :flag_types, :loan_types, :contents

  
 
  resources :projects do
    resources :files # RDM 3_26_2013
  end

  resources :organizations, :users, :scopes, :exports

  # limited access
  resources :comments, only: [:create, :destroy, :show]
  resources :flags, only: [:create, :destroy, :show]
  
  # special purpose
  resources :sessions, only: [:new, :create, :destroy]
  resources :relationships


  match '/aggregates/export', to: 'static_pages#aggregator', as: "aggregate_export"
  match '/aggregates/projects', to: 'aggregates#projects', as: "aggregate_api", :defaults=>{:format=>'json'}
  post '/users/:id/own/:owner_id', to: 'users#own'
  post '/users/:id/disown', to: 'users#disown'
  
  # Flow Classes hack 1/8/2013
  get '/projects/:project_id/flow_class', to: 'flow_classes#show', as: 'flow_class'
  post '/projects/:project_id/flow_class', to: 'flow_classes#update'
  get '/projects/:project_id/flow_class/edit', to: 'flow_classes#edit'
  post '/projects/:project_id/flow_class/edit', to: 'flow_classes#update'

  
  # Versions -- revert action, and index for all recent activity
  post '/versions/:id/revert', to: 'versions#revert', as: 'revert_version'
  get '/recent_activity', to: 'versions#index', as: 'versions'
  
  # static pages
  root to: "static_pages#home"
	get '/analyze', to: "static_pages#analyze", as: "bubbles"
  get '/downloads', to: 'static_pages#downloads', as: "downloads"
  get '/dashboard', to: 'static_pages#dashboard'
  get '/csv_analyzer', to: 'static_pages#csv_analyzer'
  get '/map', to: 'static_pages#map', as: "map"
  get '/new_map', to: 'static_pages#new_map', as: "new_map"
  get '/content/:name', to: 'contents#show_by_name'

  
  match '/signup', to: 'users#new'

  # this is for staff log in:
  match '/login', to: 'sessions#new', as: "staff_login" 

  match '/signout', to: 'sessions#destroy', via: :delete

  # this is for external log in:
  match '/signin', to: 'static_pages#signin'
  match '/ajax', to: 'static_pages#ajax'

  resources :exports

  #openauth
  match "/auth/:provider/callback", to: "sessions#create"
end
