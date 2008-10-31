ActionController::Routing::Routes.draw do |map|
  map.resource :user_session
  map.resource :account, :controller => "users"
  map.resources :users, :member => {:reset_password => :get}
  map.default "/", :controller => "user_sessions", :action => "new"
end
