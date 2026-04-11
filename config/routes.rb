Rails.application.routes.draw do
  devise_for :users
  root "home#index"

  resources :recipes do
    member do
      post :duplicate
      post :add_to_collection
      get :cook
      post :like
      delete :unlike
    end
    collection do
      get :import
      post :import_from_url
    end
    resources :reviews, only: [:create, :edit, :update, :destroy]
  end

  resources :users, only: [:show, :edit, :update] do
    member do
      post :follow
      delete :unfollow
    end
  end

  resources :grocery_lists do
    member do
      post :complete
      post :archive
      post :generate_from_meal_plan
      post :share
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
      post :use_as_template
      post :clone_from_template
      get :export_ical
    end
    resources :meal_plan_recipes, only: [:create, :update, :destroy]
  end

  resources :recipe_collections do
    member do
      post :add_recipe
      delete :remove_recipe
    end
  end

  resources :pantry_items, only: [:index, :create, :update, :destroy] do
    collection do
      get :suggest
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
