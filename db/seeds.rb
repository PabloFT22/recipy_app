# Create a demo user
demo_user = User.find_or_create_by!(email: 'demo@recipyapp.com') do |user|
  user.password = 'password123'
  user.password_confirmation = 'password123'
end

puts "Created demo user: demo@recipyapp.com / password123"
puts "\nCreating sample recipes..."

# Recipe 1
recipe1 = demo_user.recipes.find_or_create_by!(title: "Spaghetti Carbonara") do |r|
  r.description = "A traditional Italian pasta dish"
  r.servings = 4
  r.prep_time = 10
  r.cook_time = 20
  r.difficulty = "medium"
  r.is_public = true
  r.instructions = "Cook pasta. Fry pancetta. Mix eggs and cheese. Combine all."
end

if recipe1.recipe_ingredients.empty?
  parser = RecipeParserService.new("1 pound spaghetti\n6 ounces pancetta\n4 eggs\n1 cup Parmesan cheese\nSalt to taste")
  parser.parse.each do |ing|
    ingredient = IngredientFinderService.new(ing[:ingredient_name]).find_or_create
    recipe1.recipe_ingredients.create!(ingredient: ingredient, quantity: ing[:quantity], unit: ing[:unit], notes: ing[:notes])
  end
  puts "✓ Created: #{recipe1.title}"
end

# Recipe 2
recipe2 = demo_user.recipes.find_or_create_by!(title: "Chocolate Chip Cookies") do |r|
  r.description = "Soft, chewy cookies"
  r.servings = 24
  r.prep_time = 15
  r.cook_time = 12
  r.difficulty = "easy"
  r.is_public = true
  r.instructions = "Mix ingredients. Bake at 375F for 10 minutes."
end

if recipe2.recipe_ingredients.empty?
  parser = RecipeParserService.new("2 cups flour\n1 cup butter\n3/4 cup sugar\n2 eggs\n2 cups chocolate chips")
  parser.parse.each do |ing|
    ingredient = IngredientFinderService.new(ing[:ingredient_name]).find_or_create
    recipe2.recipe_ingredients.create!(ingredient: ingredient, quantity: ing[:quantity], unit: ing[:unit], notes: ing[:notes])
  end
  puts "✓ Created: #{recipe2.title}"
end

puts "\n✅ Seed data loaded!"
puts "👉 Demo account: demo@recipyapp.com / password123"
puts "👉 Visit http://localhost:3000"
