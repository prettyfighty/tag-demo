# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

5.times do
  Product.create(name: Faker::Food.fruits, description: Faker::Food.description, price: Faker::Number.within(range: 1..999999))
end

5.times do
  Product.create(name: Faker::Food.vegetables, description: Faker::Food.description, price: Faker::Number.within(range: 1..999999))
end

5.times do
  Product.create(name: Faker::Food.sushi, description: Faker::Food.description, price: Faker::Number.within(range: 1..999999))
end

5.times do
  Product.create(name: Faker::Food.dish, description: Faker::Food.description, price: Faker::Number.within(range: 1..999999))
end
