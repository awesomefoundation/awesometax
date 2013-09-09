LoveTax3::Application.routes.draw do

  devise_for :users, :controllers => { :registrations => "registrations" }
  devise_scope :user do
    get "/login" => "devise/sessions#new"
    get "/logout" => "devise/sessions#destroy"
    match '/confirm_pledge' => 'registrations#confirm_pledge'
  end


  resources :users, :only => [ :show ]

  get 'home/autocomplete_user_name'

  resource  :account, :controller => 'users'
  match     'account' => 'users#show', :as => :my_account, :method => :get
  resources :taxes do
    resources :roles
    match "search/:id" => 'roles#user_search'
  end
  resources :pledges, :only => [ :show, :create ]
  resources :comments, :only => [ :create, :destroy ]
  resources :messages, :only => [ :new, :create, :edit, :update, :destroy ]

  match 'pledges/:id/start' => 'pledges#start', :as => :start
  match 'pledges/:id/pause' => 'pledges#pause', :as => :pause
  match 'pledges/:id/stop'  => 'pledges#stop', :as =>  :stop
  match 'pledges/:id/:action', :controller => 'pledges'
  match 'pledges/:action',     :controller => 'pledges'

  match 'admin' => 'admin#index',         :as => :admin
  match 'guide' => 'home#guide',          :as => :guide
  match 'widget/mock' => 'home#mock',     :as => :mock
  match 'widget/:id.js' => 'home#widget', :format => :js
  match 'rounds/notify' => 'pledges#notify', :as => :notify  # IPNs have stale erroneous url

  root :to => "home#index"
end
