Rails.application.routes.draw do


  get '/home' => 'sittings#select_sitting'
   # post '/home' => 'sittings#select_sitting'

  mount Upmin::Engine => '/admin'

  devise_for :users, :controllers => { registrations: 'users/registrations' }

  # devise_scope :user do
  # 	root :to => "devise/sessions#new"
  # end

  devise_scope :user do
    authenticated :user do
      root 'sittings#select_sitting', as: :authenticated_root
      # match '/sessions/user', to: 'devise/sessions#create', via: :post
    end

    unauthenticated do
      # root 'devise/sessions#new', as: :unauthenticated_root
      root 'devise/sessions#new', as: :unauthenticated_root
    end
  end

 # users
  get "users/new" => "users#new", as: :users_new_user
  post "users/create_user" => "users#create", as: :users_create_user
  get "users/:id/edit" => "users#edit", as: :users_edit_user
  put "users/:id" => "users#update", as: :users_update_user

 # calendars/google authenication
  resources :calendars
  get "/auth/:provider/callback" => 'calendars#create'
  post "/calendars" => 'calendars#new'

  #sittings

  get '/sittings/refresh' => 'sittings#refresh'
  post '/sittings/refresh' => 'sittings#refresh'
  # get '/sittings/create_calendar'  => 'sittings#create_calendar'
  get '/sittings/update_calendar'  => 'sittings#update_calendar'
  get '/sittings/select_sitting'  => 'sittings#select_sitting'
  post '/sittings/select_sitting'  => 'sittings#select_sitting'
  post '/sittings/update_sitting' => 'sittings#update_sitting'
  get '/sittings/update_sitting' => 'sittings#update_sitting'
  post '/sittings/update' => 'sittings#update'
  post '/sittings/view_past_sittings' => 'sittings#view_past_sittings'
  get '/sittings/view_past_sittings' => 'sittings#view_past_sittings'


  #clients
  delete '/clients/:clients_sittings_id/cancel_attendance' => 'clients#cancel_attendance'
  post '/clients/attendance/' => 'clients#attendance'
  get '/clients/attendance', to:'clients#attendance'
  get '/clients/list_all' => 'clients#list_all'
  post '/clients/list_all' => 'clients#list_all'
  post '/clients/update_list_all_client' => 'clients#update_list_all_client'
  post '/clients/update_clients_sitting_autocomplete' => 'clients#update_clients_sitting_autocomplete'
  post '/clients/update_client_status' => 'clients#update_client_status'
  get '/clients/autocomplete', to: 'clients#autocomplete', as: 'autocomplete_client'
  # post '/clients/js_add_client_to_sitting', to: 'clients#js_add_client_to_sitting'
  get 'clients/home' => 'clients#home'
  get '/clients/schedule_meetings' => 'clients#schedule_meetings'
  post '/clients/schedule_meetings' => 'clients#schedule_meetings'
  get '/clients/:group_id/new_dropdown' =>'clients#new_dropdown'
  post '/clients/new_dropdown' =>'clients#new_dropdown'
  get '/clients/manage_clients' => 'clients#manage_clients'
  post '/clients/manage_clients' => 'clients#manage_clients'
  get '/clients/manage_inactive_clients' => 'clients#manage_inactive_clients'
  post '/clients/manage_inactive_clients' => 'clients#manage_inactive_clients'
  get '/clients/manage_absent_clients' => 'clients#manage_absent_clients'
  post '/clients/manage_absent_clients' => 'clients#manage_absent_clients'
  post '/clients/new' => 'clients#new'
  get  'clients/:id/history' => 'clients#history'
  post '/clients/:id/history' => 'clients#history'
  post '/clients/:id/edit' => 'clients#edit'
  post '/clients/:id/update' => 'clients#update'
  patch '/clients/:id/update' => 'clients#update'
  get '/clients/update' => 'clients#update'
  post '/clients/update' => 'clients#update'

  #special_status
  get '/clients/:client_id/new_special_status' => 'clients#new_special_status'
  post '/clients/update_special_status' => 'clients#update_special_status'

  #location
  post '/clients/update_location_status' => 'clients#update_location_status'

  #meetings
  post '/meetings/:meeting_id/delete_other_meeting' => 'meetings#delete_other_meeting'
  delete '/meetings/:meeting_id/delete_other_meeting' => 'meetings#delete_other_meeting'
  post '/meetings/:meeting_id/edit_other_meeting' => 'meetings#edit_other_meeting'
  get '/meetings/:meeting_id/edit_other_meeting' => 'meetings#edit_other_meeting'
  get '/meetings/:client_id/new' => 'meetings#new'
  post '/meetings/update' => 'meetings#update'
  delete '/meetings/:meeting_id/destroy' => 'meetings#destroy'
  post '/meetings/new_other_meeting' => 'meetings#new_other_meeting'
  get '/meetings/new_other_meeting' => 'meetings#new_other_meeting'
  get '/meetings/autocomplete', to: 'meetings#autocomplete', as: 'autocomplete_meeting'
  get '/meetings/show_other' => 'meetings#show_other'
  post '/meetings/show_other' => 'meetings#show_other'

  #groups
  delete '/groups/:clients_groups_id/delete_clients_groups' => 'groups#delete_clients_groups'
  delete '/groups/:id/delete_group' => 'groups#delete_group'
  get '/groups/:id/all_clients_in_group' => 'groups#all_clients_in_group'
  post '/groups/manage_groups' => 'groups#manage_groups'
  get '/groups/manage_groups' => 'groups#manage_groups'
  post '/groups/update_clients_in_group' => 'groups#update_clients_in_group'
  post '/groups/new' => 'groups#new'
  post '/groups/:id/edit' => 'groups#edit'
  get '/groups/:id/update' => 'groups#update'
  post '/groups/:id/update' => 'groups#update'
  patch '/groups/:id/update' => 'groups#update'
  get '/groups/update' => 'groups#update'
  post '/groups/update' => 'groups#update'

  #notes
  post '/notes/new' => 'notes#new'
  get '/notes/update' => 'notes#update'
  post '/notes/update' => 'notes#update'
  post '/notes/:id/edit' => 'notes#edit'
  delete '/notes/:id/destroy' => 'notes#destroy'

  #reports
  get 'reports/generate_reports' => 'reports#generate_reports'
  post 'reports/generate_reports' => 'reports#generate_reports'
  post 'reports/new' => 'reports#new'
  get 'reports/attendance_report' => 'reports#attendance_report'
  post 'reports/attendance_report' => 'reports#attendance_report'
  get 'reports/meeting_report' => 'reports#meeting_report'
  post 'reports/meeting_report' => 'reports#meeting_report'
  get 'reports/client_report' => 'reports#client_report'
  post 'reports/client_report' => 'reports#client_report'


  # resources :sessions
  # resources :users
  resources :reports
  resources :clients
  resources :meetings
  resources :monastics
  resources :sittings
  resources :clients_sittings
  resources :attendance_status_types
  resources :groups
  resources :notes

  get '/visitors/instructions' => 'visitors#instructions'

end


