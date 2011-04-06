Rails.application.routes.draw do |map|
	resources :forms, :only => [:show]
end
