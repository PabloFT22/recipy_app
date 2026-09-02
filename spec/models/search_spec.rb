require 'rails_helper'

# Search used a bare SQL LIKE, which is case-INSENSITIVE on MySQL but
# case-SENSITIVE on Postgres. These pin the portable behaviour so the
# migration to Postgres cannot silently break finding your own recipes.
RSpec.describe "Search" do
  describe Recipe, ".search" do
    let(:user) { create(:user) }
    let!(:soup) { create(:recipe, user: user, title: "Chicken Soup", description: "Warming BROTH") }
    let!(:cake) { create(:recipe, user: user, title: "Carrot Cake", description: "Very sweet") }

    it "matches a title regardless of case" do
      %w[chicken Chicken CHICKEN cHiCkEn].each do |query|
        expect(user.recipes.search(query)).to contain_exactly(soup), "failed for #{query.inspect}"
      end
    end

    it "matches a description regardless of case" do
      expect(user.recipes.search("broth")).to contain_exactly(soup)
      expect(user.recipes.search("BROTH")).to contain_exactly(soup)
    end

    it "matches on a partial word" do
      expect(user.recipes.search("hick")).to contain_exactly(soup)
    end

    it "returns nothing for a term that is absent" do
      expect(user.recipes.search("zzzzz")).to be_empty
    end

    it "treats LIKE wildcards as literal characters" do
      # A bare "%" must not behave as "match everything".
      expect(user.recipes.search("%")).to be_empty
      expect(user.recipes.search("_")).to be_empty
    end

    it "handles a blank query without raising" do
      expect { user.recipes.search("").to_a }.not_to raise_error
      expect { user.recipes.search(nil).to_a }.not_to raise_error
    end
  end

  describe Ingredient, ".search" do
    let!(:tomato) { Ingredient.create!(name: "Tomato", normalized_name: "tomato") }
    let!(:onion)  { Ingredient.create!(name: "Onion", normalized_name: "onion") }

    it "matches regardless of the query's case" do
      expect(Ingredient.search("TOM")).to contain_exactly(tomato)
      expect(Ingredient.search("tom")).to contain_exactly(tomato)
    end

    it "escapes wildcards" do
      expect(Ingredient.search("%")).to be_empty
    end
  end
end
