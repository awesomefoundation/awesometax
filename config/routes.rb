LoveTax3::Application.routes.draw do

  devise_for :user, :path => 'account', :path_names => {
    :sign_in => 'login',
    :sign_out => 'logout',
    :invitation => 'invite'
  }

  resources :users, :only => [ :show ]
  resources :taxes
  resources :pledges
  resources :comments, :only => [ :create, :destroy ]

  resource  :account, :controller => 'users'
  match 'account/history' => 'users#history', :as => :history
  
  match 'admin' => 'admin#index', :as => :admin  
  match 'guide' => 'home#guide', :as => :guide 
  match 'widget/mock' => 'home#mock',   :as => :mock
  match 'widget/:id.js' => 'home#widget', :format => :js  
  match 'rounds/notify' => 'pledges#notify', :as => :notify  # IPNs have stale erroneous url
  
  root :to => "home#index"
end
