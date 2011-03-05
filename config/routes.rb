TslRails::Application.routes.draw do
  
  resources :images

  namespace :workflow do
    match '/login' => 'user_sessions#new', :via => :get, :as => "login"
    match '/login' => 'user_sessions#create', :via => :post, :as => "login"
    match '/logout' => 'user_sessions#destroy', :as => "logout"
  end

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action
  
  resources :articles
  
  match 'workflow/' => "workflow#index"
  namespace :workflow do
    resources :articles do
      resources :authors
      resources :comments, :controller => "workflow_comments"
      resources :images
      resources :revisions
    end
    resources :headlines, :except => [:new]
    match "articles/:id/headline" => "headlines#show", :via => :get
    resources :sections do
      resources :editors
      resources :subsections
    end
    resources :users, :except => [:create]
    match "users/new" => "users#create", :via => :post
    match "users/:id/reset" => "users#reset", :via => :post
    resources :statuses, :controller => "workflow_statuses"
  end
  
  module ArticlesHelper
    def workflow_article_headline_path(article)
      workflow_article_path(article) + "/headline"
    end
  end
  
  module UsersHelper
    def reset_workflow_user_path(user)
      workflow_user_path(user) + "/reset"
    end
  end

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
