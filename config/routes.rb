LoveTax3::Application.routes.draw do

  devise_for :users do
    get "/login" => "devise/sessions#new"
    get "/logout" => "devise/sessions#destroy"
  end

  resources :users, :only => [ :show ]
  resource  :account, :controller => 'users'
  match     'account/history' => 'users#history', :as => :history
  resources :taxes
  resources :pledges
  resources :comments, :only => [ :create, :destroy ]
  
  match 'pledges/:id/start' => 'pledges#start', :as => :start
  match 'pledges/:id/pause' => 'pledges#pause', :as => :pause
  match 'pledges/:id/stop'  => 'pledges#stop', :as =>  :stop
  
  
  match 'admin' => 'admin#index', :as => :admin  
  match 'guide' => 'home#guide', :as => :guide 
  match 'widget/mock' => 'home#mock',   :as => :mock
  match 'widget/:id.js' => 'home#widget', :format => :js  
  match 'rounds/notify' => 'pledges#notify', :as => :notify  # IPNs have stale erroneous url
  match 'pledges/collect' => 'pledges#collect', :as => :collect
  
  root :to => "home#index"
end
