require 'workflow/dav'

TslRails::Application.routes.draw do

  mount Workflow::Dav::App => '/webdav'

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
  
  root :to => "articles#index"
  match '/articles' => redirect("/")
  match '/articles/:year/:month/:day/:section' => 'articles#section',
    :year => /\d+/, :month => /\d+/, :day => /\d+/
  match '/articles/:year/:month/:day/:section/:id' => 'articles#article',
    :year => /\d+/, :month => /\d+/, :day => /\d+/, :id => /\d.*/
  match '/articles/:section/:id' => "articles#article", :id => /\d.*/
  match '/articles/:section/:subsection/:id' => "articles#article"
  match '/articles/:section/:subsection' => "articles#subsection", :subsection => /\w.*/
  match '/articles/:section' => "articles#section"
  match '/authors/:author' => "articles#author"
  match '/blogs' => "blogs#index"
  
  resources :pages
  
  module WorkflowHelper
    def wiki_path
      '/wiki'
    end
  end
  
  module ArticlesHelper
    def article_path(article)
      File.join articles_path,
        article.published_at.year.to_s,
        article.published_at.month.to_s,
        article.published_at.day.to_s,
        article.section.url,
        article.slug
    end
    
    def authors_path
      "/authors"
    end
    
    def author_path(author)
      File.join authors_path, author.slug
    end
    
    def section_path(section)
      File.join articles_path, section.url
    end
    
    def subsection_path(subsection)
      File.join section_path(subsection.section), subsection.url
    end
  end
  
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
      resources :print_published_articles, :controller => 'articles/print_published_articles', :only => [:new, :create, :destroy]
      resources :web_published_articles, :controller => 'articles/web_published_articles', :only => [:new, :create, :destroy]
      
      resource :front_page, :controller => "articles/front_page", :only => [:new, :create]
    end
    resources :authors
    resources :front_page_articles, :except => [:show, :new, :create]
    resources :issues do
      resources :articles, :only => [:new, :create], :controller => "issues/articles"
    end
    resources :review_slots, :except => [:show]
    resources :sections do
      resources :editors, :controller => "sections/editors"
      resources :subsections, :controller => "sections/subsections"
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
