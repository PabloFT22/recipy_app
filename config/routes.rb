Rails.application.routes.draw do
  devise_for :users
  root "home#index"
  
  resources :recipes do
    member do
      post :duplicate
      post :add_to_collection
    end
    collection do
      get :import
      post :import_from_url
    end
  end
  
  resources :grocery_lists do
    member do
      post :complete
      post :archive
      post :generate_from_meal_plan
    end
    resources :grocery_list_items, only: [:create, :update, :destroy] do
      member do
        patch :toggle_checked
        patch :toggle_on_hand
      end
    end
  end
  
  resources :meal_plans do
    member do
      post :generate_grocery_list
    end
    resources :meal_plan_recipes, only: [:create, :update, :destroy]
  end
  
  resources :recipe_collections do
    member do
      post :add_recipe
      delete :remove_recipe
    end
  end
  
  get "up" => "rails/health#show", as: :rails_health_check
end
