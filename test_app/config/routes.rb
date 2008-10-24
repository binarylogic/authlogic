ActionController::Routing::Routes.draw do |map|
  map.resources :users
  map.resources :user_sessions
  map.resource :account, :controller => "users"
  map.logout "/logout", :controller => "user_sessions", :action => "destroy"
  map.default "/", :controller => "user_sessions", :action => "new"
end
