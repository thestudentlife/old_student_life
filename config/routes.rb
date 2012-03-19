TslRails::Application.routes.draw do

  mount Daffy, :at => '/webdav'

  devise_for :users

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action
  
  root :to => "articles#index"
  match '/articles' => redirect("/")
  match '/articles/:year/:month/:day/:section' => 'articles#section',
    :year => /\d+/, :month => /\d+/, :day => /\d+/
  match '/articles/:year/:month/:day/:section/:id' => 'articles#article',
    :year => /\d+/, :month => /\d+/, :day => /\d+/, :id => /\d.*/
  match '/articles/:section/:id' => "articles#article", :id => /\d.*/
  match '/articles/:section' => "articles#section"
  match '/authors/:author' => "articles#author"
  match '/blogs' => "blogs#index"
  match '/search' => "articles#search", :as => 'search'
  match '/wfj_and_documents' => "articles#wfj", :as => 'wfj'
  
  resources :pages
  
  match 'workflow/' => "workflow#index"
  namespace :workflow do
    resources :articles, :except => [:index, :new, :create] do
      member do
        put 'lock'
        delete 'unlock'
      end
      
      resources :authors, :controller => "articles/authors"
      resources :comments, :controller => "articles/comments"
      resources :images, :controller => "articles/images"
      resources :reviews, :controller => 'articles/reviews', :only => [:new, :create, :destroy]
      resources :revisions, :controller => "articles/revisions" do
        get 'body', :on => :member
      end
      resources :titles, :controller => "articles/titles"
      resource :publish, :controller => 'articles/publish'
      
      resource :front_page, :controller => "articles/front_page", :only => [:new, :create]
    end
    resources :authors
    resources :front_page_articles, :except => [:show, :new, :create]
    resources :issues do
      resources :articles, :only => [:new, :create], :controller => "issues/articles"
    end
    resources :photo_sets do
      resources :photos, :controller => "photo_sets/photos"
    end
    resources :review_slots, :except => [:show]
    resources :sections do
      resources :editors, :controller => "sections/editors"
      resources :subsections, :controller => "sections/subsections"
    end
    resources :users, :except => [:create] do
      collection do
        post 'new' => "users#create"
      end
      member do
        post 'reset' => "users#reset"
      end
    end
    match "users/new" => "users#create", :via => :post
    resources :statuses, :controller => "workflow_statuses"
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
