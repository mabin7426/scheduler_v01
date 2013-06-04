SchedulerV01::Application.routes.draw do
  root :to => 'events#index'
  resources :events

  # Events #
  get "/events", controller: 'events', action: 'index' #works
  post "/events", controller: 'events', action: 'create' #works
  get "/events/new", controller: 'events', action: 'new' #works

  get "/events/:id", controller: 'events', action: 'show' #works
  put "/events/:id", controller: 'events', action: 'update' #works

  get "/events/:id/edit", controller: 'events', action: 'edit' #works

  delete "/events/:id", controller: 'events', action: 'destroy' #works w/ validation!


  get "/delete_all_events", controller: 'events', action: 'delete_all_events' #works
  get "/delete_all_tasks", controller: 'events', action: 'delete_all_tasks' #works


  #Google Calendar

  get "/google_events", controller: 'events', action: 'google_events'

  # Tasks

  get "/see_tasks", controller: 'events', action: 'see_tasks'
  get "/add_tasks", controller: 'events', action: 'add_tasks'

  # Omniauth #
  get "/auth/:provider/callback" => "sessions#create"

  get "/auth/failure", to: redirect('/')

  get "/signout" => "sessions#destroy"

end
