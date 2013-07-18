Adt::Application.routes.draw do
  # codes
  
  get '/organizations/merge', to: "organizations#merge", as: "organizations_prepare_merge"
  get '/organizations/typeahead', to: "organizations#twitter_typeahead"
  post '/organizations/merge', to: "organizations#merge!", as: "organizations_execute_merge"
  get '/organizations/all_json', to: "organizations#all_json", as: "organizations_all_json"
  resources :roles, :countries, :crs_sectors, :statuses, 
  :verifieds, :oda_likes, :flow_types, :origins, :intents, # :tieds, 
  :source_types, :document_types, :organization_types, :currencies, 
  :flag_types, :loan_types, :organizations, :users, :scopes, :exports
  resources :exports
  get '/contents/typeahead', to: 'contents#twitter_typeahead'
  resources :contents

  get '/pending_content', to: 'pending_content#index', as: "pending_content"
  get '/pending_content/:pending_content_scope', to: 'pending_content#index', as: "scoped_pending_content"
  post '/pending_content/approve', to: 'pending_content#approve'
  post '/pending_content/destroy', to: 'pending_content#destroy'

  post "resources/:id/get_devoured", to: "resources#get_devoured", as: "get_devoured_resource"
  get "/resources/typeahead", to: "resources#twitter_typeahead"
  resources :resources do
    resources :pinned_projects
  end


  # Link from DG email
  match "/utm_*other" => redirect("/")

  get '/projects/typeahead', to: "projects#twitter_typeahead"
  get '/projects/suggest', to: "projects#suggest", as: "suggest_a_project"
  post '/projects/suggest', to: "projects#suggest"

  resources :projects do
    resources :files # RDM 3_26_2013
    resources :robocodes # RDM 4 12 2013
    resources :pinned_resources # RDM 6 4 2013
    resources :flow_classes
  end

  resources :datasets, id: /[0-9\.]+/

  # limited access
  resources :comments, only: [:create, :destroy, :show]
  resources :flags, only: [:create, :destroy, :show]
  
  # special purpose
  resources :sessions, only: [:new, :create, :destroy]


  get '/aggregates/export', to: 'static_pages#aggregator', as: "aggregate_export"
  get '/aggregates/projects', to: 'aggregates#projects', as: "aggregate_api", :defaults=>{:format=>'json'}
  post '/users/:id/own/:owner_id', to: 'users#own'
  post '/users/:id/disown', to: 'users#disown'
  
  
  # Versions -- revert action, and index for all recent activity
  post '/versions/:id/revert', to: 'versions#revert', as: 'revert_version'
  
  # static pages
  root to: "static_pages#home"
	get '/analyze', to: "static_pages#analyze", as: "bubbles"
  get '/downloads', to: 'static_pages#downloads', as: "downloads"
  get '/dashboard', to: 'static_pages#dashboard', as: "dashboard"
  get '/csv_analyzer', to: 'static_pages#csv_analyzer', as: "csv_analyzer"
  get '/map', to: 'static_pages#map', as: "map"
  get '/new_map', to: 'static_pages#new_map', as: "new_map"
  get '/explore', to: 'static_pages#circle_grid', as: "circle_grid"
  get '/content/:name', to: 'contents#show_by_name', as: "content_by_name"
  get '/recent', to: 'static_pages#recent', as: "recent"
  get '/MBDC_codebook', to: 'static_pages#codebook', as: "codebook"
  get '/recent_changes', to: 'static_pages#recent_changes', as: 'recent_changes'

  get '/signup', to: 'users#new'

  # this is for staff log in:
  get '/login', to: 'sessions#new', as: "staff_login" 

  match '/signout', to: 'sessions#destroy', via: :delete

  # this is for external log in:
  get '/signin', to: 'static_pages#signin'
  match '/ajax', to: 'static_pages#ajax'



  #openauth
  match "/auth/:provider/callback", to: "sessions#create"


  #404
  unless Rails.application.config.consider_all_requests_local
    match '*not_found', to: 'errors#error_404'
  end
  get 'error_404', to: 'errors#error_404'
  get 'error_500', to: 'errors#error_500'
end
