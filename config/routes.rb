ArsLovesGames::Application.routes.draw do
  
  match 'jobs/new/:id' => 'jobs#new', :as => :queue
  match 'jobs/destroy/:id' => 'jobs#destroy', :as => :destroy_job
  match 'loves/find_titles' => 'loves#find_titles', :as => :live_search
  match 'loves/revise_title' => 'loves#revise_title', :as => :revise_title
  match 'loves/update_owned' => 'loves#update_owned', :as => :update_owned
  match 'loves/update_ignored' => 'loves#update_ignored', :as => :update_ignored
  match 'loves/owned' => 'loves#owned', :as => :owned
  match 'loves/buy' => 'loves#buy', :as => :buy
  resources :jobs
  resources :loves
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

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
  root :to => "loves#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
