# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create sample users
puts "Creating sample users..."

admin = User.find_or_create_by!(email: "admin@example.com") do |user|
  user.password = "password"
  user.password_confirmation = "password"
  user.admin = true
end
puts "Created admin user: #{admin.email}"

alice = User.find_or_create_by!(email: "alice@example.com") do |user|
  user.password = "password"
  user.password_confirmation = "password"
  user.admin = false
end
puts "Created user: #{alice.email}"

bob = User.find_or_create_by!(email: "bob@example.com") do |user|
  user.password = "password"
  user.password_confirmation = "password"
  user.admin = false
end
puts "Created user: #{bob.email}"

puts "\nSample users created! You can log in with:"
puts "  Email: admin@example.com, Password: password"
puts "  Email: alice@example.com, Password: password"
puts "  Email: bob@example.com, Password: password"
puts "\nTo create a calendar, log in as one user and create a calendar for another user."
