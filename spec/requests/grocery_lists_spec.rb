require 'rails_helper'

RSpec.describe "Grocery Lists", type: :request do
  let(:user) { create(:user) }
  before { sign_in user }

  describe "GET /grocery_lists" do
    it "returns http success" do
      get grocery_lists_path
      expect(response).to have_http_status(:success)
    end

    it "renders grocery list cards when lists exist" do
      create(:grocery_list, user: user, name: "Weekly Shopping")
      get grocery_lists_path
      expect(response.body).to include("Weekly Shopping")
    end

    it "filters by status" do
      create(:grocery_list, user: user, name: "Active List", status: "active")
      create(:grocery_list, user: user, name: "Completed List", status: "completed")
      get grocery_lists_path(status: "active")
      expect(response.body).to include("Active List")
      expect(response.body).not_to include("Completed List")
    end

    it "shows empty state when no lists exist" do
      get grocery_lists_path
      expect(response.body).to include("No grocery lists found")
    end
  end

  describe "GET /grocery_lists/new" do
    it "returns http success" do
      get new_grocery_list_path
      expect(response).to have_http_status(:success)
    end

    it "renders the form" do
      get new_grocery_list_path
      expect(response.body).to include("New Grocery List")
    end
  end

  describe "POST /grocery_lists" do
    it "creates a grocery list and redirects" do
      expect {
        post grocery_lists_path, params: { grocery_list: { name: "Test List" } }
      }.to change(GroceryList, :count).by(1)
      expect(response).to redirect_to(GroceryList.last)
    end

    it "re-renders new on validation error" do
      post grocery_lists_path, params: { grocery_list: { name: "" } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "GET /grocery_lists/:id" do
    let(:grocery_list) { create(:grocery_list, user: user) }

    it "returns http success" do
      get grocery_list_path(grocery_list)
      expect(response).to have_http_status(:success)
    end

    it "renders progress bar and add item form for active lists" do
      get grocery_list_path(grocery_list)
      expect(response.body).to include("Add Item")
      expect(response.body).to include("gl-add-item-row")
    end

    it "shows items grouped by category" do
      ingredient = create(:ingredient, name: "Tomato", category: "produce")
      create(:grocery_list_item, grocery_list: grocery_list, ingredient: ingredient,
             quantity: 3, unit: "cup")
      get grocery_list_path(grocery_list)
      expect(response.body).to include("Produce")
      expect(response.body).to include("Tomato")
    end

    it "shows checked items with strikethrough class" do
      ingredient = create(:ingredient, name: "Milk", category: "dairy")
      create(:grocery_list_item, grocery_list: grocery_list, ingredient: ingredient,
             quantity: 1, unit: "cup", checked: true)
      get grocery_list_path(grocery_list)
      expect(response.body).to include("gl-item--checked")
    end

    it "shows empty state when no items" do
      get grocery_list_path(grocery_list)
      expect(response.body).to include("No items on this list")
    end
  end

  describe "GET /grocery_lists/:id/edit" do
    let(:grocery_list) { create(:grocery_list, user: user) }

    it "returns http success" do
      get edit_grocery_list_path(grocery_list)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /grocery_lists/:id" do
    let(:grocery_list) { create(:grocery_list, user: user) }

    it "updates and redirects" do
      patch grocery_list_path(grocery_list), params: { grocery_list: { name: "Updated" } }
      expect(response).to redirect_to(grocery_list)
      expect(grocery_list.reload.name).to eq("Updated")
    end
  end

  describe "DELETE /grocery_lists/:id" do
    let!(:grocery_list) { create(:grocery_list, user: user) }

    it "deletes and redirects" do
      expect { delete grocery_list_path(grocery_list) }.to change(GroceryList, :count).by(-1)
      expect(response).to redirect_to(grocery_lists_url)
    end
  end

  describe "POST /grocery_lists/:id/complete" do
    let(:grocery_list) { create(:grocery_list, user: user, status: "active") }

    it "marks as completed" do
      post complete_grocery_list_path(grocery_list)
      expect(grocery_list.reload.status).to eq("completed")
      expect(response).to redirect_to(grocery_list)
    end
  end

  describe "POST /grocery_lists/:id/archive" do
    let(:grocery_list) { create(:grocery_list, user: user, status: "active") }

    it "archives the list" do
      post archive_grocery_list_path(grocery_list)
      expect(grocery_list.reload.status).to eq("archived")
      expect(response).to redirect_to(grocery_lists_path)
    end
  end
end

RSpec.describe "Grocery List Items", type: :request do
  let(:user) { create(:user) }
  let(:grocery_list) { create(:grocery_list, user: user) }
  let(:ingredient) { create(:ingredient) }
  before { sign_in user }

  describe "POST /grocery_lists/:grocery_list_id/grocery_list_items" do
    it "adds an item by ingredient name" do
      expect {
        post grocery_list_grocery_list_items_path(grocery_list), params: {
          grocery_list_item: {
            ingredient_name: "Chicken breast",
            quantity: 2,
            unit: "lb"
          }
        }
      }.to change(GroceryListItem, :count).by(1)
      expect(response).to redirect_to(grocery_list)
    end
  end

  describe "DELETE /grocery_lists/:grocery_list_id/grocery_list_items/:id" do
    let!(:item) { create(:grocery_list_item, grocery_list: grocery_list, ingredient: ingredient) }

    it "removes the item" do
      expect {
        delete grocery_list_grocery_list_item_path(grocery_list, item)
      }.to change(GroceryListItem, :count).by(-1)
      expect(response).to redirect_to(grocery_list)
    end
  end

  describe "PATCH /grocery_lists/:grocery_list_id/grocery_list_items/:id/toggle_checked" do
    let!(:item) { create(:grocery_list_item, grocery_list: grocery_list, ingredient: ingredient, checked: false) }

    it "toggles the checked state" do
      patch toggle_checked_grocery_list_grocery_list_item_path(grocery_list, item)
      expect(item.reload.checked).to be true
    end

    it "responds with turbo_stream when requested" do
      patch toggle_checked_grocery_list_grocery_list_item_path(grocery_list, item),
            headers: { "Accept" => "text/vnd.turbo-stream.html" }
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(response.body).to include("grocery_item_#{item.id}")
      expect(response.body).to include("grocery_list_progress")
    end
  end

  describe "PATCH /grocery_lists/:grocery_list_id/grocery_list_items/:id/toggle_on_hand" do
    let!(:item) { create(:grocery_list_item, grocery_list: grocery_list, ingredient: ingredient, on_hand: false) }

    it "toggles the on_hand state" do
      patch toggle_on_hand_grocery_list_grocery_list_item_path(grocery_list, item)
      expect(item.reload.on_hand).to be true
    end

    it "responds with turbo_stream when requested" do
      patch toggle_on_hand_grocery_list_grocery_list_item_path(grocery_list, item),
            headers: { "Accept" => "text/vnd.turbo-stream.html" }
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(response.body).to include("grocery_item_#{item.id}")
    end
  end
end
