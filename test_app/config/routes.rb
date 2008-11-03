ActionController::Routing::Routes.draw do |map|
  map.resource :user_session
  map.resource :account, :controller => "users"
  map.resources :companies do |company|
    company.resource :account, :controller => "users"
    company.resource :user_session
    company.resources :users
  end
  map.resources :users, :member => {:reset_password => :get}
  map.default "/", :controller => "user_sessions", :action => "new"
end
