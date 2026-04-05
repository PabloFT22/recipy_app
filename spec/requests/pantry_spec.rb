require 'rails_helper'

RSpec.describe "Pantry", type: :request do
  let(:user) { create(:user) }
  before { sign_in user }

  describe "GET /pantry" do
    it "returns http success" do
      get pantry_path
      expect(response).to have_http_status(:success)
    end

    it "seeds default items on first visit" do
      expect(user.pantry_items.count).to eq(0)
      get pantry_path
      expect(user.pantry_items.reload.count).to be > 0
    end

    it "shows pantry items grouped by category" do
      salt = create(:ingredient, name: "salt", normalized_name: "salt", category: "spices")
      create(:pantry_item, user: user, ingredient: salt)
      get pantry_path
      expect(response.body).to include("salt")
      expect(response.body).to include("Spices")
    end
  end

  describe "POST /pantry/add_item" do
    it "adds an ingredient to the pantry" do
      expect {
        post add_item_pantry_path, params: { ingredient_name: "brown sugar" }
      }.to change(user.pantry_items, :count).by(1)
      expect(response).to redirect_to(pantry_path)
    end

    it "rejects blank names" do
      post add_item_pantry_path, params: { ingredient_name: "" }
      expect(response).to redirect_to(pantry_path)
      expect(flash[:alert]).to be_present
    end

    it "does not duplicate existing pantry items" do
      sugar = create(:ingredient, name: "sugar", normalized_name: "sugar")
      create(:pantry_item, user: user, ingredient: sugar)
      post add_item_pantry_path, params: { ingredient_name: "sugar" }
      expect(user.pantry_items.count).to eq(1)
    end
  end

  describe "DELETE /pantry/remove_item" do
    it "removes an ingredient from the pantry" do
      salt = create(:ingredient, name: "salt", normalized_name: "salt")
      create(:pantry_item, user: user, ingredient: salt)
      expect {
        delete remove_item_pantry_path, params: { ingredient_id: salt.id }
      }.to change(user.pantry_items, :count).by(-1)
      expect(response).to redirect_to(pantry_path)
    end
  end

  describe "POST /pantry/seed_defaults" do
    it "resets pantry to defaults" do
      post seed_defaults_pantry_path
      expect(user.pantry_items.reload.count).to eq(PantryItem::DEFAULT_STAPLES.size)
      expect(response).to redirect_to(pantry_path)
    end
  end
end

RSpec.describe "Pantry auto on_hand in grocery lists", type: :model do
  let(:user) { create(:user) }
  let(:grocery_list) { create(:grocery_list, user: user) }

  it "auto-marks pantry ingredients as on_hand when added to grocery list" do
    salt = create(:ingredient, name: "salt", normalized_name: "salt", category: "spices")
    sugar = create(:ingredient, name: "sugar", normalized_name: "sugar", category: "pantry")
    flour = create(:ingredient, name: "flour", normalized_name: "flour", category: "pantry")

    # salt and sugar are in pantry, flour is not
    create(:pantry_item, user: user, ingredient: salt)
    create(:pantry_item, user: user, ingredient: sugar)

    grocery_list.add_or_update_ingredient(salt, 1, 'tablespoons')
    grocery_list.add_or_update_ingredient(sugar, 2, 'cups')
    grocery_list.add_or_update_ingredient(flour, 3, 'cups')

    items = grocery_list.grocery_list_items.reload
    salt_item = items.find { |i| i.ingredient == salt }
    sugar_item = items.find { |i| i.ingredient == sugar }
    flour_item = items.find { |i| i.ingredient == flour }

    expect(salt_item.on_hand).to be true
    expect(sugar_item.on_hand).to be true
    expect(flour_item.on_hand).to be false
  end
end
